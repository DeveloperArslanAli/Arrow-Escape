class_name ThemeManager
extends RefCounted

## 8 Distinct Thematic Worlds across Levels 1–200
const WORLDS: Array[Dictionary] = [
	{
		"world_id": 1,
		"name": "Sky Breeze",
		"level_start": 1,
		"level_end": 25,
		"bg_color": Color("#EBF3FC"), # Soft ice-blue
		"header_color": Color("#3A80E0"), # Sky-blue
		"header_dark": Color("#205FBD"),
		"text_color": Color("#1E272E"),
		"arrow_palette": [
			"#2B7DE9", # Classic Blue
			"#E04848", # Ruby Red
			"#27AE60", # Emerald Green
			"#F39C12", # Tangerine Orange
			"#8E44AD", # Royal Purple
			"#F1C40F", # Sunny Yellow
			"#00CEC9", # Bright Teal
			"#E84393"  # Hot Pink
		]
	},
	{
		"world_id": 2,
		"name": "Sunset Coral",
		"level_start": 26,
		"level_end": 50,
		"bg_color": Color("#FDF2EE"), # Soft warm peach
		"header_color": Color("#E65C40"), # Coral sunset
		"header_dark": Color("#C0392B"),
		"text_color": Color("#2C1810"),
		"arrow_palette": [
			"#E65C40", # Coral Red
			"#D35400", # Burnt Orange
			"#E67E22", # Autumn Amber
			"#9B59B6", # Dusk Violet
			"#C0392B", # Deep Crimson
			"#F39C12", # Gold Ochre
			"#16A085", # Twilight Teal
			"#8E44AD"  # Deep Plum
		]
	},
	{
		"world_id": 3,
		"name": "Emerald Glade",
		"level_start": 51,
		"level_end": 75,
		"bg_color": Color("#EEF9F5"), # Mint mist
		"header_color": Color("#10AC84"), # Lush jade
		"header_dark": Color("#0E8C6B"),
		"text_color": Color("#132A22"),
		"arrow_palette": [
			"#10AC84", # Jade Green
			"#2ECC71", # Bright Mint
			"#16A085", # Sea Teal
			"#27AE60", # Forest Green
			"#F1C40F", # Sunbeam Yellow
			"#3498DB", # Waterfall Blue
			"#E67E22", # Amber Acorn
			"#9B59B6"  # Wildflower Violet
		]
	},
	{
		"world_id": 4,
		"name": "Amethyst Twilight",
		"level_start": 76,
		"level_end": 100,
		"bg_color": Color("#F6F3FF"), # Soft lilac mist
		"header_color": Color("#6C5CE7"), # Deep amethyst
		"header_dark": Color("#5641E5"),
		"text_color": Color("#201538"),
		"arrow_palette": [
			"#6C5CE7", # Amethyst Purple
			"#8854D0", # Iris Violet
			"#A29BFE", # Periwinkle
			"#E84393", # Magenta
			"#0984E3", # Night Sky Blue
			"#FD79A8", # Orchid Pink
			"#00CEC9", # Mystic Teal
			"#FAB1A0"  # Starlight Peach
		]
	},
	{
		"world_id": 5,
		"name": "Oceanic Abyss",
		"level_start": 101,
		"level_end": 125,
		"bg_color": Color("#EAF6FF"), # Crisp arctic water
		"header_color": Color("#0984E3"), # Sapphire blue
		"header_dark": Color("#0767B1"),
		"text_color": Color("#0B2238"),
		"arrow_palette": [
			"#0984E3", # Sapphire
			"#00CEC9", # Caribbean Cyan
			"#74B9FF", # Arctic Ice
			"#2B7DE9", # Deep Marine
			"#E17055", # Coral Reef
			"#55EFC4", # Seafoam
			"#F39C12", # Starfish Orange
			"#6C5CE7"  # Deep Trench Violet
		]
	},
	{
		"world_id": 6,
		"name": "Golden Dunes",
		"level_start": 126,
		"level_end": 150,
		"bg_color": Color("#FDFBF2"), # Desert ivory
		"header_color": Color("#D48806"), # Desert gold
		"header_dark": Color("#AD6800"),
		"text_color": Color("#2E2208"),
		"arrow_palette": [
			"#D48806", # Saffron Gold
			"#E67E22", # Sandstone Orange
			"#D35400", # Terra Cotta
			"#C0392B", # Canyon Red
			"#16A085", # Oasis Teal
			"#8E44AD", # Midnight Mirage
			"#27AE60", # Desert Cactus
			"#34495E"  # Slate Shadow
		]
	},
	{
		"world_id": 7,
		"name": "Cherry Blossom",
		"level_start": 151,
		"level_end": 175,
		"bg_color": Color("#FFF0F3"), # Soft sakura petal
		"header_color": Color("#D63031"), # Sakura ruby
		"header_dark": Color("#B71540"),
		"text_color": Color("#330A12"),
		"arrow_palette": [
			"#D63031", # Ruby Crimson
			"#E84393", # Sakura Pink
			"#B71540", # Wine Berry
			"#E17055", # Peach Coral
			"#6C5CE7", # Purple Orchid
			"#27AE60", # Spring Bamboo
			"#00CEC9", # River Stream
			"#F39C12"  # Autumn Leaf
		]
	},
	{
		"world_id": 8,
		"name": "Midnight Obsidian",
		"level_start": 176,
		"level_end": 200,
		"bg_color": Color("#181E24"), # Sleek dark obsidian
		"header_color": Color("#2C3E50"), # Dark metallic slate
		"header_dark": Color("#1A252F"),
		"text_color": Color("#F5F6FA"),
		"arrow_palette": [
			"#00D2D3", # Neon Cyan
			"#FF9F43", # Neon Orange
			"#EE5253", # Neon Red
			"#10AC84", # Neon Mint
			"#54A0FF", # Electric Blue
			"#5F27CD", # Electric Violet
			"#FF6B6B", # Neon Coral
			"#FECA57"  # Electric Yellow
		]
	}
]

static func get_world_index_for_level(level_id: int) -> int:
	for i in range(WORLDS.size()):
		var w = WORLDS[i]
		if level_id >= int(w["level_start"]) and level_id <= int(w["level_end"]):
			return i
	return 0

static func get_theme_for_level(level_id: int) -> Dictionary:
	var idx = get_world_index_for_level(level_id)
	return WORLDS[idx]
