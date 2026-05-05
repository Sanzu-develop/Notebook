extends Button

@export_category("Individuality")
@export var named : StringName = "Caderneta"
@export_category("text_label")
@export var text_label : Label

var initial_pos : Vector2 = Vector2.ZERO

var current_notebook : String 

func _ready() -> void:
	await get_tree().process_frame
	initial_pos = position
	
	NotebookManager.clear_complete.connect(Callable(self,"clear_notebook"))
	if is_inside_tree():
		var tween = create_tween()
		tween.tween_property(self,"modulate",Color(1.0, 1.0, 1.0, 1.0),0.75).set_ease(Tween.EASE_IN_OUT)
#
#func _gui_input(event: InputEvent) -> void:
	#if NotebookManager.is_notebook_selected(current_notebook):
		#var tween = create_tween()
		#tween.tween_property(self,"position",initial_pos - Vector2(0,30),0.2).set_ease(Tween.EASE_IN)
		##position = initial_pos - Vector2(0,30)
	#elif initial_pos != Vector2.ZERO:
		#var tween = create_tween()
		#tween.tween_property(self,"position",initial_pos,0.2).set_ease(Tween.EASE_IN_OUT)
	#
	#if event is InputEventScreenTouch:
		#if event.double_tap and NotebookManager.is_notebook_selected(current_notebook) and current_notebook:
			#NotebookManager.open_table("BookTable")
#
func set_current_notebook(new_notebook : String):
	current_notebook = new_notebook
	var note = NotebookManager.get_notebook_in_name(new_notebook)
	if note == null: return 
	rename(note.name)
#
func rename(new_name : String):
	text_label.text = new_name
	#named = new_name
	##update_book()

func _toggled(toggled_on: bool) -> void:
	
	if toggled_on: #NotebookManager.is_notebook_selected(current_notebook) and toggled_on:
		var tween = create_tween()
		tween.tween_property(self,"position",initial_pos - Vector2(0,30),0.2).set_ease(Tween.EASE_IN)
		
		select_current_book()
	
	elif not toggled_on:
		var tween = create_tween()
		tween.tween_property(self,"position",initial_pos,0.2).set_ease(Tween.EASE_IN_OUT)
#
##func update_book():
	##button.text = named
##
func select_current_book():
	if current_notebook:
		NotebookManager.select_notebook(current_notebook)
#
#func clear_notebook(path : String):
	#if path == current_notebook:
		#var tween = create_tween()
		#
		#tween.tween_property(self,"modulate",Color(1.0, 1.0, 1.0, 0.0),1.0).set_ease(Tween.EASE_IN_OUT)
		#
		#await tween.finished
		#
		#queue_free()
