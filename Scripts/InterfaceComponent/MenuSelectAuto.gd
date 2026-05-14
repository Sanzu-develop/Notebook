extends Button
class_name MenuSelectAuto

signal selected_item(index : int)

@export var distance : Vector2 = Vector2(0,-10.0)
@export var current_panel : Control

var tween : Tween

func _ready() -> void:
	if current_panel == null and get_child_count() > 0 and get_child(0) is Control:
		current_panel = get_child(0) as Control
	
	if current_panel == null : return
	
	# Inicia com os valores padrões
	current_panel.visible = false
	current_panel.modulate.a = 0.0
	
	# Adicionar a função equivalente ao botão selecionado
	if current_panel.get_child_count() > 0:
		var containers = current_panel.find_children("","Container",true,false)
		var container : Container = containers[0] if containers.size() > 0 else null
		if container:
			var childs = container.get_children()
			for i in childs.size():
				var self_button : Button = childs[i]
				
				self_button.pressed.connect(set_item.bind(i,self_button.icon))

func _pressed() -> void:
	altern_visible_panel()

func altern_visible_panel():
	if current_panel:
		if current_panel.visible:
			hide_panel()
		else:
			show_panel()

func show_panel():
	if current_panel:
		var size_panel = current_panel.size
		var new_position = Vector2(-((size_panel.x - size.x) / 2) + distance.x, -size_panel.y + distance.y)
		current_panel.position  = new_position
		
		current_panel.visible = true
		
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(current_panel,"modulate:a",1.0,0.1).set_ease(Tween.EASE_IN_OUT)

func hide_panel():
	if current_panel:
		
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(current_panel,"modulate:a",0.0,0.1).set_ease(Tween.EASE_IN)
		await tween.finished
		
		current_panel.visible = false

func set_item(index : int,iconer : Texture2D):
	icon = iconer
	hide_panel()
	selected_item.emit(index)
