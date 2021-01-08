extends Sprite


var body_regions := []
var armor_regions := []
var legs_regions := []
var head_regions := []

var voice: String
var voice_max_index: int
var main
var player


func init(_player):
	player = _player
	main = player.main
	
	
func _ready():
	build_sprite_regions()
	randomize_sprite(self, body_regions)
	randomize_sprite($Armor, armor_regions)
	randomize_sprite($Legs, legs_regions)
	randomize_sprite($Head, head_regions)
	if randf() > 0.5:
		voice = "Female"
		voice_max_index = 36
	else:
		voice = "Male"
		voice_max_index = 11


func randomize_sprite(part: Sprite, regions: Array):
	part.region_enabled = true
	part.region_rect.position = regions[randi() % regions.size()]
	pass
	
	
func build_sprite_regions():
	for y in range(0, 3):
		body_regions.append(Vector2(17, 17 * y))
	for x in range(6, 14):
		for y in range(0, 10):
			armor_regions.append(Vector2(17 * x + 1, 17 * y))
	for x in range(14, 18):
		for y in range(0, 5):
			armor_regions.append(Vector2(17 * x + 1, 17 * y))
	armor_regions.append(Vector2(902, 187))
	for x in range(3, 5):
		for y in range(0, 10):
			legs_regions.append(Vector2(17 * x + 1, 17 * y))
	legs_regions.append(Vector2(902, 187))
	for x in range(19, 23):
		for y in range(0, 12):
			head_regions.append(Vector2(17 * x + 1, 17 * y))
	for x in range(23, 27):
		for y in range(0, 8):
			head_regions.append(Vector2(17 * x + 1, 17 * y))
	for x in range(28, 32):
		for y in range(0, 9):
			head_regions.append(Vector2(17 * x + 1, 17 * y))
	head_regions.append(Vector2(902, 187))


func play_hit_sound():
	var index = (randi() % voice_max_index) + 1
	var path := "res://Player/Sounds/%sHurt/S-%s.wav" % [voice, index]	
	main.play_sound_from_file(path, position, 0)
