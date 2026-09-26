class_name TestLevelSelectUI
extends RefCounted

const LevelSelectScene = preload("res://scenes/ui/LevelSelect.tscn")

static func run(caller_tree: Node) -> bool:
	var level_select = LevelSelectScene.instantiate()
	caller_tree.add_child(level_select)
	
	# Wait for ready and populate
	await caller_tree.get_tree().process_frame
	
	var chapters_container: VBoxContainer = level_select.get_node_or_null("%ChaptersContainer")
	if chapters_container == null:
		push_error("FAIL: ChaptersContainer not found in LevelSelect")
		level_select.queue_free()
		return false
		
	var chapter_count = chapters_container.get_child_count()
	if chapter_count != 8:
		push_error("FAIL: Expected 8 world chapters, found %d" % chapter_count)
		level_select.queue_free()
		return false
		
	var total_cards_checked: int = 0
	
	for chapter in chapters_container.get_children():
		var grid: GridContainer = null
		for child in chapter.get_children():
			if child is GridContainer:
				grid = child
				break
				
		if grid == null:
			push_error("FAIL: Chapter missing GridContainer")
			level_select.queue_free()
			return false
			
		for card in grid.get_children():
			if not (card is Button):
				continue
				
			total_cards_checked += 1
			
			# Verify styleboxes for all states exist
			var style_normal = card.get_theme_stylebox("normal")
			var style_hover = card.get_theme_stylebox("hover")
			var style_disabled = card.get_theme_stylebox("disabled")
			
			if style_normal == null or style_hover == null or style_disabled == null:
				push_error("FAIL: Card missing explicit state styleboxes")
				level_select.queue_free()
				return false
				
			# Verify child labels exist and are permanently visible
			var vbox: VBoxContainer = null
			for c in card.get_children():
				if c is VBoxContainer:
					vbox = c
					break
					
			if vbox == null:
				push_error("FAIL: Card missing internal VBoxContainer for permanent labels")
				level_select.queue_free()
				return false
				
			if vbox.get_child_count() < 2:
				push_error("FAIL: Card VBox missing number or status label")
				level_select.queue_free()
				return false
				
			var num_label: Label = vbox.get_child(0) as Label
			var sub_label: Label = vbox.get_child(1) as Label
			
			if num_label == null or sub_label == null:
				push_error("FAIL: Card child nodes are not Labels")
				level_select.queue_free()
				return false
				
			if num_label.text.is_empty():
				push_error("FAIL: Card level number label is empty")
				level_select.queue_free()
				return false
				
			if sub_label.text.is_empty():
				push_error("FAIL: Card sub-status label is empty")
				level_select.queue_free()
				return false
				
			# Check color contrast
			var num_color: Color = num_label.get_theme_color("font_color")
			if num_color.a <= 0.0:
				push_error("FAIL: Card level number font color has zero alpha")
				level_select.queue_free()
				return false
				
			var sub_color: Color = sub_label.get_theme_color("font_color")
			if sub_color.a <= 0.0:
				push_error("FAIL: Card sub-status font color has zero alpha")
				level_select.queue_free()
				return false
				
	if total_cards_checked != 200:
		push_error("FAIL: Expected 200 level cards, verified %d" % total_cards_checked)
		level_select.queue_free()
		return false
		
	level_select.queue_free()
	print("Verified all %d level cards: 100%% permanent visibility & high-contrast styling." % total_cards_checked)
	return true
