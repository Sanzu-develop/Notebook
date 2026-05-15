extends LineEdit
class_name ComumLine

@export var data : DrawObjectData 
var run : bool = true

var ghost = char(8203)

func _ready() -> void:
	# Importante conectar o sinal se não estiver no editor
	if not text_changed.is_connected(interact):
		text_changed.connect(interact)
	
	focus_entered.connect(_on_focus_entered)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var camera_global = get_tree().root.get_viewport().get_camera_2d()
		if camera_global is SensitiveCam: camera_global.enable_move_camera = not event.pressed
		if event.pressed:
			if self.caret_column < 1:
				self.caret_column = 1
	
	if event is InputEventScreenDrag:
		if self.caret_column < 1 and not self.text.is_empty():
			return_previous_line()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			accept_event()
			pass_next_line()

func _on_focus_entered():
	if self.text.is_empty():
		self.text = ghost
		caret_column = 1

func set_data(new_data : DrawObjectData):
	run = false
	data = new_data
	var parent = get_parent_control()
	
	self.text = data.text
	self.alignment = data.alignment # Corrigido de .anchor para .alignment
	self.add_theme_color_override("font_color", data.color)
	
	# Melhor usar o tamanho do parent para o resize
	if data.resize and parent:
		self.custom_minimum_size.x = parent.size.x
	else:
		self.custom_minimum_size = data.size
		
	self.z_index = data.z_index
	run = true

func interact(_new_text: String) -> void:
	if not run: return
	
	if self.text.is_empty():
		self.text = ghost
		self.caret_column = 1
		return_previous_line()
		return
	
	# Salva a posição do cursor para não perder o foco no meio do texto
	var new_text = self.text
	var old_caret = self.caret_column
	
	#if new_text.length() > 0 and new_text.begins_with(ghost):
		#new_text = new_text.right(-1)
		#old_caret = new_text.length()
	
	set_new_text(new_text, false)
	self.caret_column = min(old_caret, self.text.length())

func set_new_text(new_text : String, last_caret: bool = true):
	run = false # Trava para evitar loops de sinais
	
	var res = text_width_in_max(new_text.replace(ghost,""))
	var caret_initial_value = self.text.length()
	self.text = ghost + res["new_text"]
	data.text = self.text.replace(char(8203),"")
	
	if not res["rest_text"].is_empty():
		pass_next_line(res["rest_text"])
	
	if last_caret: 
		self.caret_column = self.text.length()
	else:
		var caret_value = self.text.length()
		if caret_value > caret_initial_value:
			self.caret_column = max(1,caret_value - caret_initial_value)
	
	run = true

func text_width_in_max(target_text : String) -> Dictionary:
	var font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size") # Corrigido: font_size
	var max_width = self.size.x - 20.0 # Margem maior para segurança
	
	var result = {"new_text": target_text, "rest_text": "", "original_text": target_text}
	
	if font.get_string_size(target_text, self.alignment, -1, font_size).x > max_width:
		var i = target_text.length()
		# Busca o ponto de corte
		while i > 0 and font.get_string_size(target_text.left(i), self.alignment, -1, font_size).x > max_width:
			i -= 1
		
		result["new_text"] = target_text.left(i)
		result["rest_text"] = target_text.right(-i)
	
	return result

func pass_next_line(rest_text : String = ""):
	var next = find_next_valid_focus()
	if next is LineEdit: # Verifica se é um campo de texto
		next.grab_focus()
		
		if next.text.is_empty(): next.text = ghost
		
		if not rest_text.is_empty():
			# Se a próxima linha já tiver texto, concatena a sobra no início dela
			var novo_texto_proxima = ghost + (rest_text + next.text).replace(ghost,"")
			if next.has_method("set_new_text"):
				next.set_new_text(novo_texto_proxima, next.text.is_empty())
			else:
				next.text = novo_texto_proxima

func return_previous_line():
	var prev = find_prev_valid_focus()
	if prev is LineEdit:
		prev.grab_focus()
		
		if prev.text.is_empty(): prev.text = ghost
		
		prev.caret_column = prev.text.length()
		# Opcional: Se quiser deletar a linha atual quando subir, adicione lógica aqui
