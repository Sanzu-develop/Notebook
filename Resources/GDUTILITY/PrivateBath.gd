extends Node
class_name Bath

signal go

func bath(init : int, end : int, per_frame : int = 4):
	for i in range(init,end,per_frame):
		for j in range(per_frame):
			if i + j >= end: break
			go.emit()
		await get_tree().process_frame
