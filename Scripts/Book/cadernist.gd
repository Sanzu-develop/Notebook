extends Panel

@export_category("Sets")
@export var current_page := 0

@export_category("Childs")
@export var list_pages : HBoxContainer

@export_category("Resources")
@export var notebook : NotebookData

@export_category("Packs")
@export var Page : PackedScene

var pages : Dictionary[int,Control] = {}


var ok := false

signal go


func _ready() -> void:
	await get_tree().process_frame
	ok = true
	go.emit()

func go_to(local : Vector2):
	var current_offset := Vector2(-size.x / 2, size.y / 2)
	var delta_move := local + current_offset
	
	var tween = create_tween()
	tween.tween_property(self,"global_position",delta_move,0.3)

func load_notebook(new : NotebookData):
	notebook = new#.duplicate(true)
	
	if not ok: await go
	
	for i in list_pages.get_children():
		i.queue_free()
	
	for i in range(2):
		create_page(i,list_pages)
	load_pages(0)

func load_pages(new_page : int):
	new_page = always_par(new_page)
	current_page = new_page
	
	load_current_page()
	##//////////
	
	#Process atual page
	#load_and_visible_verify(current_page,list_pages,true)
	
	#if current_page > 1:
		#load_and_visible_verify(current_page - 2,list_pages,false)
	#
	#if current_page < notebook.pages.size() - 2:
		#load_and_visible_verify(current_page + 2,list_pages,false)
	#pass

func load_current_page():
	pages[0].load_new_page(notebook.pages[current_page])
	pages[1].load_new_page(notebook.pages[current_page + 1])

func create_page(page_id : int, parent : Control):
	pages[page_id] = SceneFactory.spawn(Page.duplicate(true),parent)
	pages[page_id].load_new_page(notebook.pages[page_id])

func delete_page(page_id : int):
	pages[page_id].queue_free()
	pages.erase(page_id)

#func load_and_visible_verify(page_id : int,parent : Control, page_visible : bool = false):
	#page_id = always_par(page_id)
	#
	#if not current_pages.has(page_id):
		#load_page(page_id,parent)
	#if not current_pages.has(page_id + 1):
		#load_page(page_id + 1,parent)
	#visible_page(page_id,page_visible)
	#visible_page(page_id + 1,page_visible)

#func delete_per_distance(margin := 1):
	#current_page = always_par(current_page)
	#
	#var min_page = max(current_page - margin * 2,0)
	#var max_page = min(current_page + margin * 2,notebook.pages.size() - 1)
	#
	#for key in current_pages:
		#if key < min_page and min_page < current_page or key > max_page and max_page > current_page:
			#delete_page(key)
			#delete_page(key+1)

func always_par(number : int, min_value := 0, max_value := notebook.pages.size() -1) -> int:
	number = number if number % 2 == 0 else number + 1
	
	number = max(number,min_value)
	number = min(number,max_value)
	
	return number

func pass_page(count : int):
	var result = always_par(current_page + count * 2)
	load_pages(result)
