extends Panel

signal finashed_atualize_data

@export var page : PageData
var page_id : int = -1

@export_category("Intern")
@export var list_components : HFlowContainer
@export var texture_page : TextureRect

@export_category("Packs")
@export var components : Dictionary[String,PackedScene]
@export var line_path : String = "res://Scenes/BooksComponents/Line.tscn"

var tween : Tween

func atualize_data():
	var childs = list_components.get_children()
	
	for i in childs.size():
		if i >= page.objects.size(): break
		
		var data = page.objects[i]
		var notebook = childs[i]
		
		set_data_notebook_component(data,notebook)
	
	finashed_atualize_data.emit()

func load_new_page(page_data : PageData, new_page_id : int = 0):
	page = page_data
	pass_animation()
	await get_tree().process_frame
	create_itens()

# Cria todos os itens necessários
func create_itens(per_frame := 4):
	var space_y : float = get_space()
	var current_index : int = 0
	var total_objects : int = page.objects.size()
	
	# Condição: Enquanto houver espaço E ainda houver itens na lista
	while space_y > 4 and current_index < total_objects:
		
		for j in range(per_frame):
			# Verifica se já processamos todos os itens dentro do for
			if current_index >= total_objects:
				break
			
			var item = page.objects[current_index]
			var item_height = item.size.y + list_components.get_theme_constant("v_separation")
			
			# Verifica se esse item específico cabe no espaço restante
			if space_y - item_height < 0:
				# Se não cabe, paramos tudo (ou tratamos a quebra de página)
				space_y = -1 
				break
			
			# Se couber, instanciamos e subtraímos o espaço
			space_y -= item_height
			
			var packed_scene = components[item.type]
			force_child(packed_scene, list_components, current_index)
			
			# Avançamos o índice global
			current_index += 1
		
		# Aguarda o próximo frame para continuar o lote
		await get_tree().process_frame
	
	atualize_data()

# Obter espaço disponível
func get_space() -> float:
	var space_y = list_components.size.y
	var v_separation = list_components.get_theme_constant("v_separation")
	var childs = list_components.get_children()
	
	for child in childs:
		var space_occuped = child.size.y
		
		space_y -= space_occuped + v_separation
	
	return space_y

# Recalcular espaço disponível
func recalcule_space(item_size_y : float, current_space : float) -> float:
	var v_separation = list_components.get_theme_constant("v_separation")
	
	current_space -= item_size_y + v_separation
	
	print(current_space)
	
	return current_space

# Garante que haverá um filho
func force_child(new_child : PackedScene , parent : Control, positioned : int = -1) -> Control: 
	# filho já criado
	var final_child = SceneFactory.spawn(new_child,parent) 
	
	# Exclui o filho antigo caso ele exista e/ou for diferente do outro
	if interval(positioned,0,parent.get_child_count() -2):
		# Node a ser substituído
		var old_node : Control = parent.get_child(positioned)
		
		# Verificar se há necessidade de exclusão
		if old_node.get_class() == final_child.get_class():
			final_child.queue_free()
			return old_node
		old_node.queue_free()
	
	return final_child

# Dando as instruções pro no
func set_data_notebook_component(current_draw_resource : DrawObjectData, current_object : Control):
	current_object.set_data(current_draw_resource)

# Verifica se um valor está em um intervalo
func interval(value , min_value, max_value) -> bool:
	if value >= min_value and value <= max_value: return true
	return false

# Animação de troca de folha
func pass_animation():
	set_texture_region()
	texture_page.custom_minimum_size.x = self.size.x
	
	await finashed_atualize_data
	
	if tween: tween.kill()
	tween = create_tween()
	
	tween.tween_property(texture_page,"custom_minimum_size:x",0.0,0.2)
	tween.parallel().tween_property(texture_page,"size:x",0.0,0.2)

func set_anchor_page(anchor : int):
	if anchor == -1:
		texture_page.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	elif anchor == 1:
		texture_page.set_anchors_preset(Control.PRESET_RIGHT_WIDE)

func set_texture_region():
	var page_size = self.size
	
	var render = SubViewport.new()
	render.size = Vector2i(page_size)
	render.transparent_bg = true
	render.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	var screen_img = get_viewport().get_texture().get_image()
	
	var rect_page = get_global_rect()
	
	var img = screen_img.get_region(Rect2i(rect_page.position,rect_page.size))
	#var viewport = get_viewport()
	#var img = viewport.get_texture().get_image()
	#var region : Rect2i = Rect2i(global_position,size)
	#var tex = ImageTexture.create_from_image(img.get_region(region))
	
	var tex = ImageTexture.create_from_image(img)
	
	texture_page.texture = tex
