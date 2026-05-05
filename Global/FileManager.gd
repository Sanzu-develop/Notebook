extends Node


var paths := {"current" : null}
var base_path := "user://"
var version := "0.0.1"

# --------------------
# Pastas
# --------------------
func create_folder(path: String) -> bool:
	return DirAccess.make_dir_recursive_absolute(path) == OK

func folder_exist(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)

# --------------------
# Arquivos
# --------------------

func save_archive(path: String, archive : Resource) -> bool:
	return ResourceSaver.save(archive,path) == OK

func archive_exist(path: String) -> bool:
	return FileAccess.file_exists(path)

func clear_archive(path: String) -> bool:
	if not archive_exist(path):
		return false

	return DirAccess.remove_absolute(path) == OK

# --------------------
# Limpeza recursiva
# --------------------
func clear_folder(path: String) -> bool:
	if not folder_exist(path):
		print("A pasta não existe:", path)
		return false

	var dir := DirAccess.open(path)
	if dir == null:
		print("Não foi possível acessar a pasta:", path)
		return false

	dir.list_dir_begin()
	var nome := dir.get_next()

	while nome != "":
		if nome != "." and nome != "..":
			var full_path := path.path_join(nome)

			if dir.current_is_dir():
				clear_folder(full_path)
			else:
				DirAccess.remove_absolute(full_path)

		nome = dir.get_next()

	dir.list_dir_end()
	DirAccess.remove_absolute(path)
	return true

# --------------------
# ConfigFile
# --------------------
func save_cfg(section: String, key, value, path: String) -> bool:
	var cfg := ConfigFile.new()

	if archive_exist(path):
		var err := cfg.load(path)
		if err != OK:
			return false

	cfg.set_value(section, key, value)
	return cfg.save(path) == OK

func load_cfg(path: String) -> ConfigFile:
	if not archive_exist(path):
		return null

	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return null

	return cfg


#.........

func string_for_path(list : Array[String], use_base_path : bool = true) -> String:
	var new_path : String = base_path if use_base_path else ""
	
	for item in list:
		new_path = new_path.path_join(item)
	
	return new_path

func get_all_files(path : String) -> Dictionary:
	var files := {"dir":[],"file":[],"error":false}
	var dir := DirAccess.open(path)
	if dir == null:
		files["error"] = true
		return files

	dir.list_dir_begin()
	var nome := dir.get_next()

	while nome != "":
		if nome != "." and nome != "..":
			var full_path := path.path_join(nome)

			if dir.current_is_dir():
				files["dir"].append(full_path)
			else:
				files["file"].append(full_path)

		nome = dir.get_next()

	dir.list_dir_end()
	
	return files
