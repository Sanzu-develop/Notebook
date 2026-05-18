extends Control

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

@export var UI : Dictionary[String,Control]

func _ready() -> void:
	var term_button = get_ui("term")
	var licence_button = get_ui("licence")
	var confirm_button = get_ui("confirm")
	var first_image = get_ui("first_image")
	
	if not term_button or not licence_button or not confirm_button:
		return
	
	term_button.pressed.connect(verifiy_all_conditions)
	licence_button.pressed.connect(verifiy_all_conditions)
	confirm_button.pressed.connect(confirmation)
	
	await get_tree().process_frame
	
	var tween = create_tween()
	tween.tween_property(first_image,"modulate:a",0.0,1.0).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	
	first_image.visible = false
	
	var accept_term = FileManager.get_setting("sistem","accept_term")
	confirmation(accept_term)

func get_ui(ui_key: String) -> Control:
	var ui : Control
	if UI.has(ui_key):
		ui = UI[ui_key]
	return ui

func verifiy_all_conditions() -> bool:
	var term_button = get_ui("term")
	var licence_button = get_ui("licence")
	var confirm_button = get_ui("confirm")
	
	if not term_button or not licence_button or not confirm_button:
		return false
	
	confirm_button.disabled = not (term_button.button_pressed and licence_button.button_pressed)
	
	return term_button.button_pressed and licence_button.button_pressed

func confirmation(force_confirm : bool = false):
	if verifiy_all_conditions() or force_confirm: 
		if not force_confirm: 
			FileManager.set_setting("sistem","accept_term",true)
			FileManager.save_settings_to_disk()
		NotebookManager.open_table("BookCase")
	else: 
		var consent = get_ui("consent")
		if consent:
			consent.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(consent,"modulate:a",1.0,0.75)
		print("Accept all terms first")
