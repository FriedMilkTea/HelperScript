extends Control

var help_steps = []
var current_step = 0
var overlay: ColorRect
var info_label: Label
var highlight_rect: Rect2
var highlight_node: Control

func _ready():
	create_help_steps()
	create_overlay()
	show_help_step()

func create_help_steps():
	help_steps = [
		{
			"text": "Welcome to the game!",
			"highlight_node": %CheatPanel,
			"condition": func(): return %GameManager.has_loaded  # Always allow progression
		},
		{
			"text": "This is the gathering panel \n collect 20 water",
			"highlight_node": %Gathering,
			"condition": func(): return %ResourceManager.check_spend("water", 20),  # Example condition
			"text_position": 0.5
		},
		{
			"text": "Click anywhere to finish the tutorial",
			"highlight_node": null,
			"condition": func(): return true  # Always allow progression
		}
	]

func create_overlay():
	anchor_right = 1
	anchor_bottom = 1
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://cutout_overlay_shader.gdshader")
	overlay.material = shader_material
	
	add_child(overlay)
	
	info_label = Label.new()
	info_label.set_anchors_preset(Control.PRESET_CENTER)
	info_label.anchor_top = 0.1
	info_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_color_override("font_color", Color.WHITE)
	info_label.add_theme_font_size_override("font_size", 30)
	add_child(info_label)

func show_help_step():
	if current_step < help_steps.size():
		var step = help_steps[current_step]
		info_label.text = step["text"]
		if step.has("text_position"):
			print("layoutmode: " + str(info_label.layout_mode))
			info_label.anchor_top = step.text_position
		highlight_node = step["highlight_node"]
		
		if highlight_node:
			await get_tree().process_frame
			
			highlight_rect = highlight_node.get_global_rect()
			var overlay_rect = overlay.get_global_rect()
			
			var padding = Vector2(4, 4)
			highlight_rect = highlight_rect.grow(padding.x)
			
			var center = (highlight_rect.position - overlay_rect.position + highlight_rect.size / 2) / overlay_rect.size
			var size = highlight_rect.size / (2 * overlay_rect.size)
			
			overlay.material.set_shader_parameter("center", center)
			overlay.material.set_shader_parameter("size", size)
		else:
			# If no highlight_node, make the entire screen interactable
			highlight_rect = get_viewport_rect()
			overlay.material.set_shader_parameter("center", Vector2(0.5, 0.5))
			overlay.material.set_shader_parameter("size", Vector2(1, 1))
	else:
		queue_free()  # Remove the help overlay when done

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if not highlight_rect.has_point(event.position):
				get_viewport().set_input_as_handled()
				print("Clicked OUTSIDE help")
			else:
				check_condition()
				print("Clicked INSIDE help")

func _process(_delta):
	# Continuously check condition for non-click based progression
	check_condition()
	pass

func check_condition():
	if current_step < help_steps.size():
		var condition_func = help_steps[current_step]["condition"]
		if condition_func.call():
			current_step += 1
			show_help_step()
