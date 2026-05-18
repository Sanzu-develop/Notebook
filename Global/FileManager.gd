extends Node

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."
const CONFIG_PATH = "user://settings.cfg"

# Dicionário na memória com os valores Padrão (Fallback)
var config_data := {
	"sistem": {
		"accept_term": false,
		"version": "0.0.2 Demo Alpha"
	},
	"audio": {
		"volume_geral": 1.0,
		"mutado": false
	},
	"ui": {
		"touch_viewer":{
			"size":3.0
		}
	}
}

var not_save_keys : Array[String] = ["version"]

var paths := {"current" : null}
var base_path := "user://"

signal loaded


# --------------------
# AutoLoad
# --------------------

# Chamado quando o FileManager entra na árvore (Início do jogo)
func _ready() -> void:
	load_settings_from_disk()

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


# --------------------
# Sistema de Configuração Centralizado
# --------------------

# Altera um valor na memória. Rápido e sem travar o jogo gravando em disco.
func set_setting(section: String, key: String, value) -> void:
	if not config_data.has(section):
		config_data[section] = {}
	config_data[section][key] = value

# Pega um valor da memória. Se não existir, retorna o valor padrão fornecido.
func get_setting(section: String, key: String, default_value = null):
	if config_data.has(section) and config_data[section].has(key):
		return config_data[section][key]
	return default_value

# Carrega o arquivo do disco para a memória
func load_settings_from_disk() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		# Se não existe, salva o padrão para criar o arquivo pela primeira vez
		print("Not initial settings, creating ...")
		save_settings_to_disk()
		return

	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		for section in cfg.get_sections():
			for key in cfg.get_section_keys(section):
				if not not_save_keys.has(key): set_setting(section, key, cfg.get_value(section, key))

	loaded.emit()

# Grava todo o estado atual da memória para o disco de uma vez só
func save_settings_to_disk() -> bool:
	var cfg := ConfigFile.new()
	
	# Passa tudo do dicionário para o objeto ConfigFile
	for section in config_data:
		for key in config_data[section]:
			if not not_save_keys.has(key): cfg.set_value(section, key, config_data[section][key])
	return cfg.save(CONFIG_PATH) == OK
