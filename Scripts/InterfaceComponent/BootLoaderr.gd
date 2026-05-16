extends Control

const configuration_path = "user://configuration.save"

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
	tween.tween_property(first_image,"modulate:a",0.0,0.5).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	
	first_image.visible = false

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

func confirmation():
	if verifiy_all_conditions(): NotebookManager.open_table("BookCase")
