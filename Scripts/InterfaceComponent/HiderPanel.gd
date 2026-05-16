extends Panel
class_name HiderPanelV

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

@export_group("Modifiers")
@export var open : bool = false
@export_range(-512.0,512.0) var max_y_open : float = 256.0

@export_group("Childs")
@export var childs : Dictionary[String,Control]

var tween : Tween 

func _ready() -> void:
	# Define o botão mestre
	if not childs.keys().has("OpenedButton"):
		var button_list = find_children("","Button",true,false)
		
		if button_list.size() > 0:
			childs["OpenedButton"] = button_list[0]
		else:
			print("HiderPanelV não encontrou um botão válido para realizar sua função. /n %s" % self.name)
			return
	
	# Adiciona configurações essenciais no botão
	
	var opened_button = childs["OpenedButton"] as Button
	
	opened_button.toggle_mode = true
	opened_button.button_pressed = open
	opened_button.pressed.connect(show_or_hide_panel)
	pass

func show_or_hide_panel():
	var opened_button : Button = get_hider_button()
	
	open = opened_button.button_pressed
	
	if tween: tween.kill()
	tween = create_tween()
	
	if open:
		show_panel()
	else:
		hide_panel()

func show_panel():
	var opened_button : Button = get_hider_button()
	var parent_button : Control = opened_button.get_parent_control()
	
	tween.tween_property(self,"custom_minimum_size:y",max_y_open,0.1)
	
	if parent_button.get_child_count() > 0:
		var containers = parent_button.find_children("","Container",false,false)
		
		var final_value = 1.0
		
		for container in containers:
			container.visible = true
			
			tween.parallel().tween_property(container,"modulate:a",final_value,0.1)

func hide_panel():
	var opened_button : Button = get_hider_button()
	var parent_button : Control = opened_button.get_parent_control()
	
	tween.tween_property(self,"custom_minimum_size:y",opened_button.size.y,0.1)
	
	if parent_button.get_child_count() > 0:
		var containers = parent_button.find_children("","Container",false,false)
		
		var final_value = 0.0
		
		for container in containers:
			tween.parallel().tween_property(container,"modulate:a",final_value,0.1)
			
			await tween.finished
			container.visible = false

func get_hider_button() -> Button:
	return childs["OpenedButton"] 

func spawn_all_dependencies():
	var margin_extern = MarginContainer.new()
	childs["margin_extern"] = SceneFactory.spawn(margin_extern,self)
	
	var hbox = HBoxContainer.new()
	childs["hbox"] = SceneFactory.spawn(hbox,margin_extern)
