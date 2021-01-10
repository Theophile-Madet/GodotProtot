extends Node2D

class_name PlayerSkin

var regions := {}
var current_region := {}

var voice: String
var voice_max_index: int
var player

const parts = ["Body", "Head", "Torso", "Legs"]
var sprites = {}


func init(_player):
	player = _player
	
	
func _ready():
	build_sprite_regions()
	for part in parts:
		sprites[part] = get_node(part)
		sprites[part].region_enabled = true
		current_region[part] = randomize_sprite(part)

	if randf() > 0.5:
		voice = "Female"
		voice_max_index = 36
	else:
		voice = "Male"
		voice_max_index = 11


func randomize_sprite(part: String) -> int:
	var region_index = randi() % regions[part].size()
	set_part_region(part, region_index)
	return region_index
	

func set_part_region(part: String, region_index: int):
	sprites[part].region_rect.position = regions[part][region_index]	
	current_region[part] = region_index
	
	
func build_sprite_regions():
	for part in parts:
		regions[part] = []
	
	for y in range(0, 3):
		regions["Body"].append(Vector2(17, 17 * y))
	for x in range(6, 14):
		for y in range(0, 10):
			regions["Torso"].append(Vector2(17 * x + 1, 17 * y))
	for x in range(14, 18):
		for y in range(0, 5):
			regions["Torso"].append(Vector2(17 * x + 1, 17 * y))
	regions["Torso"].append(Vector2(902, 187))
	for x in range(3, 5):
		for y in range(0, 10):
			regions["Legs"].append(Vector2(17 * x + 1, 17 * y))
	regions["Legs"].append(Vector2(902, 187))
	for x in range(19, 23):
		for y in range(0, 12):
			regions["Head"].append(Vector2(17 * x + 1, 17 * y))
	for x in range(23, 27):
		for y in range(0, 8):
			regions["Head"].append(Vector2(17 * x + 1, 17 * y))
	for x in range(28, 32):
		for y in range(0, 9):
			regions["Head"].append(Vector2(17 * x + 1, 17 * y))
	regions["Head"].append(Vector2(902, 187))


func play_hit_sound():
	var index = (randi() % voice_max_index) + 1
	var path := "res://Player/Sounds/%sHurt/S-%s.wav" % [voice, index]	
	Main.play_sound_from_file(path, position, 0)
