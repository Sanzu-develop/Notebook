extends LineEdit
class_name ComumLine

@export var data : DrawObjectData 

var run : bool = true

func set_data(new_data : DrawObjectData):
	run = false
	
	data = new_data
	
	var parent = get_parent_control()
	
	self.text = data.text
	self.alignment = data.anchor
	self.add_theme_color_override("font_color",data.color)
	self.add_to_group("ComumLine")
	
	self.custom_minimum_size = data.size if not data.resize else Vector2(parent.size.x,data.size.y)
	self.z_index = data.z_index
	
	run = true

func interact(_new_text: String) -> void:
	if run: 
		run = false
		data.text = self.text
		run = true
