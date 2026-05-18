extends Panel

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

@export_group("Sets")
@export var current_page := 0
@export var pages_alignment : Array[LayoutPreset]

@export_group("Childs")
@export var list_pages : HBoxContainer
@export var name_notebook : LineEdit
@export_subgroup("Texture_pass_anim")
@export var texture_page_left : Sprite2D
@export var texture_page_right : TextureRect

@export_group("Resources")
@export var notebook : NotebookData

@export_group("Paths")
@export var path_name : String

@export_group("Packs")
@export var Page : PackedScene

var pages : Dictionary[int,Control] = {}

var selected_pages : Array[int] = []

signal touching(event : InputEvent)
signal moving(event : InputEvent)
signal loading_finashed


func _gui_input(event: InputEvent) -> void:
	# Ativa ou desativa a câmera
	if event is InputEventScreenTouch:
		var camera_target : Camera2D = get_tree().current_scene.cam
		
		camera_target.set_process_input(not event.pressed)
		
		touching.emit(event)
		if event.pressed :
			var parent = get_parent()
			
			parent.move_child(self,-1)
			
			self.scale = Vector2(0.95,0.95)
			self.modulate.a = 0.8
			
			NotebookManager.select_notebook(path_name,false)
		
		else:
			self.scale = Vector2(1.0,1.0)
			self.modulate.a = 1.0

	# Move o caderno
	if event is InputEventScreenDrag:
		global_position += event.relative
		
		moving.emit(event)	
	
	#var t = SubViewport.new()
	
	#t.get_texture().get_image()

func go_to(local : Vector2):
	var current_offset := Vector2(-size.x / 2, size.y / 2)
	var delta_move := local + current_offset
	
	var tween = create_tween()
	tween.tween_property(self,"global_position",delta_move,0.3)

func load_notebook(new : NotebookData, new_path : String):
	notebook = new#.duplicate(true)
	path_name = new_path
	name_notebook.text = notebook.name
	
	if not is_inside_tree(): await self.ready
	
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
	pages[0].load_new_page(notebook.pages[current_page],current_page)
	pages[1].load_new_page(notebook.pages[current_page + 1],current_page + 1)
	
	loading_finashed.emit()

func create_page(page_id : int, parent : Control):
	var new_subviewport_container = SceneFactory.spawn(Page.duplicate(true),parent) as SubViewportContainer
	var containers = new_subviewport_container.find_children("","Control",true,false)
	
	if containers.size() < 1:
		new_subviewport_container.queue_free()
		return
	
	#new_subviewport_container.set_anchors_preset(pages_alignment[page_id])

	pages[page_id] = containers[0]
	pages[page_id].finashed_atualize_data.connect(cadernist_finashed_load.bind(page_id))
	pages[page_id].focus.connect(select_page.bind(page_id))
	pages[page_id].load_new_page(notebook.pages[page_id],page_id)

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
	#var sub_r = pages[1].get_parent() as SubViewport
	#
	#if sub_l and sub_r:
		#var tex_l = sub_l.get_texture()
		#var tex_r = sub_r.get_texture()
		#
		#texture_page_left.texture = tex_l
		#texture_page_right.texture = tex_r
	
	var result = always_par(current_page + count * 2)
	#
	#var sub_c_l = sub_l.get_parent() as SubViewportContainer
	#var sub_c_r = sub_r.get_parent() as SubViewportContainer
	#
	#var min_size_sl_x = sub_c_l.custom_minimum_size.x
	#var min_size_sr_x = sub_c_r.custom_minimum_size.x
#
	#texture_page_left.custom_minimum_size.x = min_size_sl_x
	#texture_page_right.custom_minimum_size.x = min_size_sr_x
	#
	#texture_page_left.z_index = 0
	#texture_page_right.z_index = 0
	
	#anim_pages()
	
	load_pages(result)
	
	#await loading_finashed
	#
	#var tween = create_tween()
	#
	#if result > current_page:
		#texture_page_right.z_index = 1
		#
		#sub_c_l.custom_minimum_size.x = 0
		#
		#tween.tween_property(texture_page_right,"custom_minimum_size:x",0.0,0.75)
		#
		#await tween.finished
		#
		#tween.tween_property(sub_c_l,"custom_minimum_size:x",min_size_sl_x,0.75)
		#
		#await tween.finished

func select_page(id: int, multiple : bool = false):
	if pages.has(id):
		if not multiple:
			selected_pages.clear()
			selected_pages.push_back(id)

func modify_item(function: String, value: Variant):
	var pages_ = get_pages_selecteds()
	
	for page in pages_:
		if page.has_method("modify_item"):
			page.modify_item(function,value)

func cadernist_finashed_load(id_page: int):
	if pages.has(0) and pages.has(1):
		var itens_0 = pages[0].get_itens()
		var itens_1 = pages[1].get_itens()
		
		var book_table = get_tree().current_scene
		
		if itens_0.size() > 0 and itens_1.size() > 0:
			if id_page == 0:
				var last_item_0 = itens_0[itens_0.size() - 1]
				var first_item_1 = itens_1[0]
				
				last_item_0.focus_next = first_item_1.get_path()
				first_item_1.focus_previous = last_item_0.get_path()
			else:
				var last_item_1 = itens_1[itens_1.size() - 1]
				var first_item_0 = itens_0[0]
				
				var callable_pass = Callable(book_table,"pass_count").bind(1)
				var callable_return = Callable(book_table,"pass_count").bind(-1)
				
				last_item_1.focus_next = first_item_0.get_path()
				first_item_0.focus_previous = last_item_1.get_path()
				
				if not last_item_1.pass_item.is_connected(callable_pass):
					last_item_1.pass_item.connect(callable_pass)
				if not first_item_0.return_item.is_connected(callable_return):
					first_item_0.return_item.connect(callable_return)

func get_pages_selecteds() -> Array[Control]:
	var selected_page : Array[Control] = []
	
	for page_id in selected_pages:
		var page = pages[page_id]
		selected_page.push_back(page)
	
	return selected_page

#func anim_pages(passing: bool = true):
	#var tween = create_tween()
	#var sub_l = pages[0].get_parent() as SubViewport
#
	#var img = sub_l.get_texture().get_image()
	#texture_page_left.global_position = sub_l.get_parent().global_position
	#texture_page_left.texture = ImageTexture.create_from_image(img)
	#texture_page_left.scale.x = 1.0
	#
	#tween.tween_property(texture_page_left,"scale:x",-1.0,0.5)
	
	#texture_page_left.modulate.a = 1.0

func rename(text: String):
	if name_notebook.text.length() >= 1:
		notebook.name = name_notebook.text
