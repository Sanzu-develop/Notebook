extends Node
class_name MoreFunction # More Functions

const COPYRIGHT = "Copyright (c) 2026 Sanzu_dev - All rigthss reserved."

func get_recursive_parent_control(node) -> Control:
	
	var p = node.get_parent()
	
	while p != null:
		if p is Control:
			return p
		
		p = p.get_parent()
	
	return null
