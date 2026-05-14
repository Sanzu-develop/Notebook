extends Control


@export var cam : Camera2D

@export var books_spawn : Control

@export var cadernist : PackedScene

@export var all_notebooks : Array[Control]

@export_group("UI")
@export var UI : Dictionary[String,Node2D]


func _ready() -> void:
	await get_tree().process_frame
	
	var all_notebook_selected : Dictionary = NotebookManager.get_current_select(-1)
	
	# Pegar todos ooscadernos e spawna-los
	if not all_notebook_selected.is_empty():
		
		for key in all_notebook_selected.keys():
			
			var notebook_data_spawn = NotebookManager.get_notebook_in_name(key)
			
			if notebook_data_spawn != null: 
				spawn_notebook(notebook_data_spawn,key)
	
	#print(NotebookManager.get_notebook_selected_key())

func spawn_notebook(notebook_resource : NotebookData, key : String):
	var cadern = SceneFactory.spawn(cadernist,books_spawn)

	cadern.touching.connect(Callable(self,"cadernist_is_event"))

	all_notebooks.append(cadern)

	# Adicionar a referência do no
	NotebookManager.set_notebook_node(key,cadern)
	
	if not cadern.is_inside_tree(): await cadern.ready
	
	cadern.go_to(cam.global_position)
	cadern.load_notebook(notebook_resource,key)


# ----------
# Viewer
# ----------

func cadernist_is_event(event : InputEvent) -> void:
	var ui_name : String = "TouchViewer"
	
	if not UI.has(ui_name): return
	
	if event is InputEventScreenTouch:
		var value = event.pressed
		UI[ui_name].view_touch(value)


# ----------
# ButtomSignal
# ----------

func pass_page() -> void:
	pass_count(1)

func pass_count(count):
	var selected = NotebookManager.get_current_select(-1)
	
	var property = "Node"
	for key in selected.keys():
		if selected[key].has(property): selected[key][property].pass_page(count)

func return_page() -> void:
	pass_count(-1)

func _on_save_pressed() -> void:
	save_current_notebook()

func save_current_notebook():
	var selected = NotebookManager.get_current_select(-1)
	
	var property = "Resource"
	for key in selected.keys():
		var notebook = selected[key][property]
		
		NotebookManager.save_notebook(notebook,key,false)

func _on_quit_pressed() -> void:
	for cadern in all_notebooks:
		var path_name = cadern.path_name
		
		NotebookManager.select_notebook(path_name,true)
	
	NotebookManager.open_table("BookCase")
