extends Label

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

var version = ""

func _ready() -> void:
	atualize_version()

func atualize_version():
	version = FileManager.get_setting("sistem","version","un_version")
	
	var new_text = "Versão: %s \n %s" % [version,COPYRIGHT]
	
	self.text = new_text
