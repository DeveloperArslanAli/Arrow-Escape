extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const LevelManager = preload("res://scripts/core/level_manager.gd")

@onready var grid_container: GridContainer = %LevelGrid
@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_populate_levels()

func _on_visibility_changed() -> void:
	if visible:
		_populate_levels()

func _populate_levels() -> void:
	# Clear existing cards
	for child in grid_container.get_children():
		child.queue_free()
		
	var total_levels: int = LevelManager.get_total_levels_count()
	var highest_unlocked: int = SaveManager.get_highest_unlocked_level()
	
	for lvl_id in range(1, total_levels + 1):
		var is_unlocked: bool = lvl_id <= highest_unlocked
		var stars: int = SaveManager.get_level_stars(lvl_id)
		
		var card: Button = Button.new()
		card.custom_minimum_size = Vector2(100, 110)
		card.disabled = not is_unlocked
		
		# Format card text
		var card_text: String = "Level %d\n" % lvl_id
		if is_unlocked:
			var stars_text: String = ""
			for s in range(stars):
				stars_text += "★"
			for s in range(3 - stars):
				stars_text += "☆"
			card_text += stars_text
		else:
			card_text += "🔒"
			
		card.text = card_text
		card.alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		var level_to_load = lvl_id
		card.pressed.connect(func():
			AudioManager.play_tap()
			GameManager.start_level(level_to_load)
		)
		
		grid_container.add_child(card)

func _on_back_pressed() -> void:
	AudioManager.play_tap()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
