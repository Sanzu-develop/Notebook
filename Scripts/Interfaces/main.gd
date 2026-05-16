extends Control

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

@export_category("Modify")
@export var max_line := 12
@export var max_page := 20
@export var base_path := "user://NoteBooks"

@export_category("Childs")
@export var book_list : VFlowContainer

@export_category("Paneis")
@export var ExcludeBackGround : ColorRect
@export var CreateCadernPanel : Panel

@export_category("Resources")
@export var notebook : NotebookData = NotebookData.new()
@export var page : PageData = PageData.new()
@export var line : LineData = LineData.new()

@export_category("Packs")
@export var book : PackedScene

var books : Dictionary[String,Control] = {}


func _ready() -> void:
	NotebookManager.loading_complete.connect(Callable(self,"loading_complete"))
	#NotebookManager.clear_complete.connect(Callable(self,"clear_complete"))
	
	await get_tree().process_frame
	NotebookManager.load_notebook_list()

# @-

func loading_complete(path : String,notebook_data : NotebookData):
	if notebook_data: create_book(path)

#func clear_complete(notebook_path : String):
	#clear_notebook(notebook_path)

# -@

func show_or_hide_panel(panel: Control, show_ : bool):
	ExcludeBackGround.visible = show_
	panel.visible = show_

func create_book(book_path : String):
	if books.keys().has(book_path): return
	var new_book = SceneFactory.spawn(book,book_list)
	new_book.set_current_notebook(book_path)
	books[book_path] = new_book

#func clear_notebook(path : String):
	#for i in books.keys():
		#if books[i].current_notebook == path:
			#books[i].queue_free()
#
func open_pressed() -> void:
	if NotebookManager.has_selected():
		NotebookManager.open_table("BookTable")

func create_pressed() -> void:
	show_or_hide_panel(CreateCadernPanel,true)
	#NotebookManager.generete_cadern("Cadernim")

func delete_pressed() -> void:
	var target = NotebookManager.get_current_select(0)
	if target.is_empty(): return
	var target_name = target.keys()[0]
	NotebookManager.clear_notebook(target_name,false)

func _on_exit_pressed() -> void:
	get_tree().quit()
