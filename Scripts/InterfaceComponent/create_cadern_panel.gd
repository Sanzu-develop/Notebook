extends Panel

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

@export var line_name : LineEdit


func confirm_create_pressed() -> void:
	create()

func rename_pressed(_new_text: String) -> void:
	create()

func create():
	var value = line_name.text.length()
	
	if value < 1 : return
	
	NotebookManager.generete_cadern(line_name.text)
	
	var parent = get_parent()
	
	parent.show_or_hide_panel(self,false)
