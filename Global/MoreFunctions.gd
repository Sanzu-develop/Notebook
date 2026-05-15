extends Node
class_name MoreFunction # More Functions

func get_recursive_parent_control(node) -> Control:
	
	var p = node.get_parent()
	
	while p != null:
		if p is Control:
			return p
		
		p = p.get_parent()
	
	return null
