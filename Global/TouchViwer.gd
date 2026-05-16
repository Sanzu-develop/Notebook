extends AnimatedSprite2D
class_name TouchViwer

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

func _ready() -> void:
	view_touch(false)

func view_touch(view : bool):
	set_process(view)
	self.visible = view

func _process(_delta: float) -> void:
	self.global_position = get_global_mouse_position()
