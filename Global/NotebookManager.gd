extends Node

# NotebookManager

var base_path := "user://NoteBooks"

var line_path = "res://Resources/BooksComponents/ComumLine.tres"

var table : Dictionary = {
	"BookTable" : load("res://Scenes/Interfaces/BookTable.tscn"),
	"BookCase" : load("res://Scenes/Interfaces/main.tscn")
	
}

var notebooks : Dictionary = {"Selected":{}, # "user://caminho" : { "Resource" : notebook_resource, "Node" : Nde2D"}
"Notebook":{
	
}
}

var loaded := false

signal loading_complete(path : String,current_notebook : NotebookData)
signal saved(ok : bool)
signal generated_notebook
signal clear_complete(notebook_path : String)



func _ready() -> void:
	await get_tree().process_frame
	if not FileManager.folder_exist(base_path):
		print("Criando...")
		print("Create = ",FileManager.create_folder(base_path))
	#load_notebook_list()

## Notebook Sistem

func generete_cadern(named : String = "Caderneta",path : String = base_path,max_line := 12, max_page := 20,per_frame := 4):
	var local_archive = path + named + ".tres"
	if FileManager.archive_exist(local_archive):
		return
	
	var notebook := NotebookData.new()
	notebook.name = named
	notebook.pages.resize(max_page)
	
	
	#Pages
	for i in range(0,max_page,per_frame):
		for j in range(per_frame):
			if i + j >= notebook.pages.size(): break
			var page := PageData.new()
			page.objects.resize(max_line)
		
			var line := load(line_path)
			
			#Lines
			for ls in range(0,max_line,per_frame):
				for lc in range(per_frame):
					if ls + lc >= page.objects.size(): break
					line.id = ls + lc
					page.objects[ls + lc] = line.duplicate(true)
				await get_tree().process_frame
			
			page.id = i + j
			notebook.pages[i + j] = page
			
	generated_notebook.emit()
	save_notebook(notebook,path)

func save_notebook(current_notebook : NotebookData, path : String, use_name : bool = true) -> bool:
	var notebook_name = current_notebook.name + ".tres"
	var path_save = FileManager.string_for_path([path,notebook_name],false) if use_name else path
	#if FileManager.archive_exist(path_save): 
		#saved.emit(false)
		#return false
	#await get_tree().process_frame
	var ok : bool = FileManager.save_archive(path_save,current_notebook)
	saved.emit(ok)
	load_notebook_list()
	return ok

func load_notebook_list(path : String = base_path) -> bool:
	loaded = false
	
	var files = FileManager.get_all_files(path)
	
	if files["error"] or files["file"].size() == 0:
		loaded = true
		return false
	
	var current_notebook : NotebookData = null
	
	for i in files["file"]:
		current_notebook = load(i)
		
		if not current_notebook is NotebookData: break
		
		create_notebook_cache(i,current_notebook)
			
		loading_complete.emit(i,current_notebook)


	
	loaded = true
	return true

func clear_notebook(path : String, use_base_path : bool = true):
	var notebook_path = base_path.path_join(path) if use_base_path else path
	if notebooks["Selected"].has(notebook_path): notebooks["Selected"].erase(notebook_path)
	if notebooks["Notebook"].has(notebook_path): notebooks["Notebook"].erase(notebook_path)
	FileManager.clear_archive(notebook_path)
	clear_complete.emit(notebook_path)

## Notebook Cache

func create_notebook_cache(notebook_path : String, notebook_resource : NotebookData, node_reference : Control = null):
	notebooks["Notebook"][notebook_path] = {"Resource":notebook_resource,"Node":node_reference}

## Get

func get_notebook_in_name(notebook_path : String) -> NotebookData:
	if not notebooks["Notebook"].has(notebook_path) : return null
	return notebooks["Notebook"][notebook_path]["Resource"]

func get_current_select(index := -1) -> Dictionary:
	if not has_selected(): return {}
	
	var list = notebooks["Selected"]
	var current_selected : Dictionary = {}
	
	if index <= -1: return list
	else:
		var id_c := 0
		for key in list.keys():
			if index == id_c:
				current_selected[key] = list[key]
				return current_selected
			id_c += 1
	
	return notebooks["Selected"]

## Set

func set_notebook_node(path : String,current_node : Control) -> bool:
	if not has_notebook(path): return false
	
	notebooks["Notebook"][path]["Node"] = current_node
	
	return true

## Select && Deselect

func select_notebook(notebook_path : String, select_peer := false):
	if notebooks["Notebook"].has(notebook_path):
		if not select_peer:
			for current_notebook_path in notebooks["Selected"].keys():
				if current_notebook_path != notebook_path: notebooks["Selected"].erase(current_notebook_path)
		if not notebooks["Selected"].has(notebook_path):
			notebooks["Selected"][notebook_path] = notebooks["Notebook"][notebook_path]

func deselect_notebook(notebook_path : String, apply_all := false):
	if apply_all:
		notebooks["Selected"].clear()
	
	else: 
		notebooks["Selected"].erase(notebook_path)

## Verification

func has_selected() -> bool:
	return notebooks["Selected"].is_empty() == false

func has_notebook(notebook_path : String) -> bool:
	return notebooks["Notebook"].has(notebook_path)

func is_notebook_selected(path : String) -> bool:
	return notebooks["Selected"].has(path)

func is_current_notebook_selected(path : String) -> bool:
	return notebooks["Selected"].keys()[0] == path

## Abrir outra base

func open_table(current_table : String):
	if table.has(current_table): 
		for i in notebooks["Notebook"].keys():
			var reference = notebooks["Notebook"][i]
			reference["Node"] = null
		
		get_tree().change_scene_to_packed(table[current_table])
