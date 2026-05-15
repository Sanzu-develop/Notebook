extends Camera2D
class_name SensitiveCam

@export_group("Configurações")
@export var sensibility_zoom := 0.005
@export var sensibility_move := 1.0
@export var zoom_min := 0.5
@export var zoom_max := 3.0

var enable_move_camera := true
var touch_points := {} 
var last_distance := 0.0

func _input(event: InputEvent) -> void:
	# 1. GESTÃO DE TOQUES
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			# Verificação crucial: Só permitimos mover se o toque inicial 
			# NÃO for em um elemento do grupo "Block"
			if event.index == 0:
				enable_move_camera = not is_pos_blocking_ui(event.position)
		else:
			touch_points.erase(event.index)
			if event.index == 0:
				enable_move_camera = false
			if touch_points.size() < 2:
				last_distance = 0.0

	# 2. MOVIMENTAÇÃO E PINÇA (ZOOM)
	if event is InputEventScreenDrag:
		if not enable_move_camera: return
		
		touch_points[event.index] = event.position

		# ZOOM COM DOIS DEDOS (Pinça)
		if touch_points.size() >= 2:
			var p1 = touch_points[0]
			var p2 = touch_points[1]
			var current_distance = p1.distance_to(p2)
			
			if last_distance > 0:
				var delta = current_distance - last_distance
				var zoom_amount = delta * sensibility_zoom
				var new_zoom = clamp(zoom.x + zoom_amount, zoom_min, zoom_max)
				zoom = Vector2(new_zoom, new_zoom)
			
			last_distance = current_distance
		
		# MOVIMENTO COM UM DEDO
		elif touch_points.size() == 1 and enable_move_camera:
			# Multiplicamos pela escala do zoom para o arrasto ser preciso
			global_position -= event.relative * (1.0 / zoom.x) * sensibility_move

func is_pos_blocking_ui(_pos: Vector2) -> bool:
	var hovered_control = get_viewport().gui_get_hovered_control()
	
	# Verificação recursiva simples: se o objeto ou qualquer pai dele for "Block"
	var check_node = hovered_control
	while check_node != null:
		if check_node.is_in_group("Block"):
			return true
		check_node = check_node.get_parent()
		
	return false

#@export var enable : bool = false
#@export_category("Caracteristicas")
#@export_group("Velocidades")
#@export var drag_speed: float = 1.0
#@export var zoom_speed: float = 0.05
#
#@export_group("Limites e Suavização")
#@export var min_zoom: float = 0.5
#@export var max_zoom: float = 3.0
#@export var smoothing: float = 15.0 # Quanto maior, mais rápido segue o dedo
#
#var target_zoom: float = 1.0
#var target_position: Vector2
#var touches = {}
#
#func _ready():
	#target_position = position
	#target_zoom = zoom.x
#
#func _on_gui_input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch:
		#if event.pressed:
			#touches[event.index] = event.position
		#else:
			#touches.erase(event.index)
			##enable = false
#
	#if event is InputEventScreenDrag:
		#touches[event.index] = event.position
		#
		#if touches.size() == 1:
			## Ajusta o destino baseado no arrasto
			#target_position -= event.relative * (1.0 / zoom.x) * drag_speed
			#
		#elif touches.size() == 2:
			#var finger_positions = touches.values()
			#var dist = finger_positions[0].distance_to(finger_positions[1])
			#var prev_dist = (finger_positions[0] - event.relative).distance_to(finger_positions[1])
			#
			#if event.index == 1:
				#prev_dist = finger_positions[0].distance_to(finger_positions[1] - event.relative)
			#
			#var zoom_factor = dist / prev_dist
			#target_zoom = clamp(target_zoom * zoom_factor, min_zoom, max_zoom)
#
#func _process(delta):
	## Interpolação suave (Lerp)
	#position = position.lerp(target_position, smoothing * delta)
	#var zoom_value = lerp(zoom.x, target_zoom, smoothing * delta)
	#zoom = Vector2(zoom_value, zoom_value)
#
#func go_to(local : Vector2, aproximate : float = target_zoom):
	#target_position = local
	#target_zoom = aproximate
