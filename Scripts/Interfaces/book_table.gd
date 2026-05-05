extends Control


@export var cam : Camera2D

@export var books_spawn : Control

@export var cadernist : PackedScene

@export var all_notebooks : Array[Control]


func _ready() -> void:
	await get_tree().process_frame
	var notebook_data_spawn = NotebookManager.get_notebook_selected()
	if notebook_data_spawn != null: spawn_notebook(notebook_data_spawn)
	
	#print(NotebookManager.get_notebook_selected_key())

func spawn_notebook(notebook_resource : NotebookData):
	var cadern = SceneFactory.spawn(cadernist,books_spawn)

	all_notebooks.append(cadern)

	# Adicionar a referência do no
	var key = NotebookManager.get_notebook_selected_key()
	NotebookManager.set_notebook_node(key,cadern)
	
	while cadern.ok == false:
		await get_tree().process_frame
	
	cadern.go_to(cam.global_position)
	cadern.load_notebook(notebook_resource)

func pass_page() -> void:
	pass_count(1)

func pass_count(count):
	var selected = NotebookManager.get_current_select()
	
	var key = selected.keys()[0]
	var property = "Node"
	
	selected[key][property].pass_page(count)

func return_page() -> void:
	pass_count(-1)

func _on_save_pressed() -> void:
	save_current_notebook()

func save_current_notebook():
	var key : String = NotebookManager.get_notebook_selected_key()
	
	if key.is_empty(): return
	
	var notebook = NotebookManager.get_notebook_in_name(key)
	
	if notebook == null: return 
	
	
	NotebookManager.save_notebook(notebook,key,false)


func _on_quit_pressed() -> void:
	NotebookManager.open_table("BookCase")
