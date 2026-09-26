extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const LevelManager = preload("res://scripts/core/level_manager.gd")
const ThemeManager = preload("res://scripts/core/theme_manager.gd")

@onready var scroll_container: ScrollContainer = %Scroll
@onready var chapters_container: VBoxContainer = %ChaptersContainer
@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_populate_levels()

func _on_visibility_changed() -> void:
	if visible:
		_populate_levels()

func _populate_levels() -> void:
	# Clear existing children
	for child in chapters_container.get_children():
		child.queue_free()
		
	var total_levels: int = LevelManager.get_total_levels_count()
	var highest_unlocked: int = SaveManager.get_highest_unlocked_level()
	var target_focus_node: Control = null
	
	for world in ThemeManager.WORLDS:
		var start_lvl: int = int(world["level_start"])
		var end_lvl: int = mini(int(world["level_end"]), total_levels)
		if start_lvl > total_levels:
			break
			
		var chapter_vbox = VBoxContainer.new()
		chapter_vbox.add_theme_constant_override("separation", 12)
		
		# Compute stars in this chapter
		var world_stars: int = 0
		var world_unlocked_any: bool = false
		for lvl in range(start_lvl, end_lvl + 1):
			world_stars += SaveManager.get_level_stars(lvl)
			if lvl <= highest_unlocked:
				world_unlocked_any = true
				
		var max_possible_stars: int = (end_lvl - start_lvl + 1) * 3
		
		# Chapter Header Panel
		var header_panel = PanelContainer.new()
		var header_style = StyleBoxFlat.new()
		var h_color: Color = world["header_color"]
		header_style.bg_color = Color(h_color.r, h_color.g, h_color.b, 0.12)
		header_style.border_color = h_color
		header_style.border_width_left = 3
		header_style.border_width_top = 0
		header_style.border_width_right = 0
		header_style.border_width_bottom = 0
		header_style.corner_radius_top_left = 8
		header_style.corner_radius_bottom_left = 8
		header_style.corner_radius_top_right = 8
		header_style.corner_radius_bottom_right = 8
		header_style.content_margin_left = 16
		header_style.content_margin_right = 16
		header_style.content_margin_top = 8
		header_style.content_margin_bottom = 8
		header_panel.add_theme_stylebox_override("panel", header_style)
		
		var header_hbox = HBoxContainer.new()
		var title_label = Label.new()
		title_label.text = "World %d · %s" % [world["world_id"], world["name"]]
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.add_theme_color_override("font_color", h_color)
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(title_label)
		
		var progress_label = Label.new()
		if world_unlocked_any:
			progress_label.text = "★ %d / %d" % [world_stars, max_possible_stars]
			progress_label.add_theme_color_override("font_color", h_color.lerp(Color.BLACK, 0.2))
		else:
			progress_label.text = "🔒 Locked"
			progress_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.8))
		progress_label.add_theme_font_size_override("font_size", 16)
		header_hbox.add_child(progress_label)
		
		header_panel.add_child(header_hbox)
		chapter_vbox.add_child(header_panel)
		
		# Grid for this chapter
		var grid = GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		
		for lvl_id in range(start_lvl, end_lvl + 1):
			var is_unlocked: bool = lvl_id <= highest_unlocked
			var stars: int = SaveManager.get_level_stars(lvl_id)
			var is_current: bool = (lvl_id == highest_unlocked)
			
			var card: Button = Button.new()
			card.custom_minimum_size = Vector2(0, 80)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.disabled = not is_unlocked
			card.text = "" # Avoid theme button text rendering
			
			# StyleBoxes for all 5 interactive states
			var style_normal = StyleBoxFlat.new()
			style_normal.corner_radius_top_left = 12
			style_normal.corner_radius_top_right = 12
			style_normal.corner_radius_bottom_left = 12
			style_normal.corner_radius_bottom_right = 12
			
			var style_hover = StyleBoxFlat.new()
			style_hover.corner_radius_top_left = 12
			style_hover.corner_radius_top_right = 12
			style_hover.corner_radius_bottom_left = 12
			style_hover.corner_radius_bottom_right = 12
			
			var style_pressed = StyleBoxFlat.new()
			style_pressed.corner_radius_top_left = 12
			style_pressed.corner_radius_top_right = 12
			style_pressed.corner_radius_bottom_left = 12
			style_pressed.corner_radius_bottom_right = 12
			
			var style_focus = StyleBoxFlat.new()
			style_focus.corner_radius_top_left = 12
			style_focus.corner_radius_top_right = 12
			style_focus.corner_radius_bottom_left = 12
			style_focus.corner_radius_bottom_right = 12
			
			if not is_unlocked:
				var locked_bg = Color("#ECEFF1")
				var locked_border = Color("#CFD8DC")
				style_normal.bg_color = locked_bg
				style_normal.border_color = locked_border
				style_normal.border_width_left = 1
				style_normal.border_width_top = 1
				style_normal.border_width_right = 1
				style_normal.border_width_bottom = 1
				
				style_hover.bg_color = locked_bg
				style_hover.border_color = locked_border
				style_hover.border_width_left = 1
				style_hover.border_width_top = 1
				style_hover.border_width_right = 1
				style_hover.border_width_bottom = 1
				
				style_pressed.bg_color = locked_bg
				style_focus.bg_color = locked_bg
			else:
				if is_current:
					style_normal.bg_color = Color.WHITE
					style_normal.border_color = h_color
					style_normal.border_width_left = 2
					style_normal.border_width_top = 2
					style_normal.border_width_right = 2
					style_normal.border_width_bottom = 2
					style_normal.shadow_color = Color(h_color.r, h_color.g, h_color.b, 0.25)
					style_normal.shadow_size = 4
					style_normal.shadow_offset = Vector2(0, 2)
					target_focus_node = card
				else:
					style_normal.bg_color = Color.WHITE
					style_normal.border_color = Color("#E2E8F0")
					style_normal.border_width_left = 1
					style_normal.border_width_top = 1
					style_normal.border_width_right = 1
					style_normal.border_width_bottom = 1
					style_normal.shadow_color = Color(0, 0, 0, 0.04)
					style_normal.shadow_size = 3
					style_normal.shadow_offset = Vector2(0, 2)
					
				# Hover: gentle chapter tint with accent border (NOT generic blue theme!)
				style_hover.bg_color = Color(h_color.r, h_color.g, h_color.b, 0.08)
				style_hover.border_color = h_color
				style_hover.border_width_left = 2
				style_hover.border_width_top = 2
				style_hover.border_width_right = 2
				style_hover.border_width_bottom = 2
				
				# Pressed: subtle depressed shade
				style_pressed.bg_color = Color("#E2E8F0")
				style_pressed.border_color = h_color
				style_pressed.border_width_left = 2
				style_pressed.border_width_top = 2
				style_pressed.border_width_right = 2
				style_pressed.border_width_bottom = 2
				
				# Focus
				style_focus.bg_color = Color.WHITE
				style_focus.border_color = h_color
				style_focus.border_width_left = 2
				style_focus.border_width_top = 2
				style_focus.border_width_right = 2
				style_focus.border_width_bottom = 2
				
			card.add_theme_stylebox_override("normal", style_normal)
			card.add_theme_stylebox_override("hover", style_hover)
			card.add_theme_stylebox_override("pressed", style_pressed)
			card.add_theme_stylebox_override("focus", style_focus)
			card.add_theme_stylebox_override("disabled", style_normal)
			
			# Safeguard font color overrides
			card.add_theme_color_override("font_color", Color("#1E293B"))
			card.add_theme_color_override("font_hover_color", Color("#1E293B"))
			card.add_theme_color_override("font_pressed_color", Color("#1E293B"))
			card.add_theme_color_override("font_focus_color", Color("#1E293B"))
			card.add_theme_color_override("font_disabled_color", Color("#94A3B8"))
			
			# Child VBox for permanent, high-contrast labels
			var vbox = VBoxContainer.new()
			vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			vbox.add_theme_constant_override("separation", 2)
			
			# Level Number Label
			var num_label = Label.new()
			num_label.text = str(lvl_id)
			num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			num_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if is_unlocked:
				num_label.add_theme_font_size_override("font_size", 20)
				num_label.add_theme_color_override("font_color", Color("#1E293B"))
			else:
				num_label.add_theme_font_size_override("font_size", 18)
				num_label.add_theme_color_override("font_color", Color("#94A3B8"))
			vbox.add_child(num_label)
			
			# Sub-label: Stars, PLAY badge, or Lock
			var sub_label = Label.new()
			sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			if is_unlocked:
				if stars > 0:
					var stars_text: String = ""
					for s in range(stars):
						stars_text += "★ "
					for s in range(3 - stars):
						stars_text += "☆ "
					sub_label.text = stars_text.strip_edges()
					sub_label.add_theme_color_override("font_color", Color("#F59E0B")) # Warm amber gold
					sub_label.add_theme_font_size_override("font_size", 13)
				else:
					sub_label.text = "PLAY"
					sub_label.add_theme_color_override("font_color", h_color)
					sub_label.add_theme_font_size_override("font_size", 12)
			else:
				sub_label.text = "🔒"
				sub_label.add_theme_color_override("font_color", Color("#94A3B8"))
				sub_label.add_theme_font_size_override("font_size", 13)
			vbox.add_child(sub_label)
			
			card.add_child(vbox)
			
			var level_to_load = lvl_id
			card.pressed.connect(func():
				AudioManager.play_tap()
				GameManager.start_level(level_to_load)
			)
			grid.add_child(card)
			
		chapter_vbox.add_child(grid)
		chapters_container.add_child(chapter_vbox)
		
	# Scroll to target focus node if visible
	if target_focus_node != null and is_instance_valid(target_focus_node):
		_scroll_to_node.call_deferred(target_focus_node)

func _scroll_to_node(node: Control) -> void:
	if scroll_container != null and is_instance_valid(node):
		scroll_container.ensure_control_visible(node)

func _on_back_pressed() -> void:
	AudioManager.play_tap()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
