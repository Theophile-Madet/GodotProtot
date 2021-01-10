extends Control

var player: Node2D
onready var player_skin: PlayerSkin = player.get_node("PlayerSkin")

var player_sprites := {}
var ui_sprites := {}
var labels := {}
var tweens = {}

const parts = ["Body", "Head", "Torso", "Legs"]


func init(_player):
	player = _player
	Main.add_child(self)
	

func _ready():
	var player_index = player.player_index
	$PlayerNumber.text = "Player %s" % player_index
	
	if player_index == 2 or player_index == 4:
		rect_position.x = Main.viewport_size.x / 2
		
	if player_index == 3 or player_index == 4:
		rect_position.y = Main.viewport_size.y / 2
		
	for part in parts:
		player_sprites[part] =  player_skin.get_node(part)
		ui_sprites[part] =  get_node(part)
		labels[part] =  get_node("Label%s" % part)
		update_ui(part)
	
	
func _process(_delta):
	if Main.game_state != GameState.GameState.CHOOSE_SKIN:
		return
		
	for part in parts:
		if Input.is_action_just_pressed("player_%s_skin_%s_left" % [player.player_index, part]):
			set_sprite_region(part, -1)
		if Input.is_action_just_pressed("player_%s_skin_%s_right" % [player.player_index, part]):
			set_sprite_region(part, 1)
	
	
func update_ui(part: String):
	labels[part].text = "%s / %s" % [player_skin.current_region[part] + 1, player_skin.regions[part].size()]
	
	var tween: Tween
	
	if !tweens.has(part):
		tween = Tween.new()
		add_child(tween)
		tweens[part] = tween
		
	tween = tweens[part]
	var sprite: Sprite = ui_sprites[part]
	tween.stop(sprite, "region_rect:position")
	var target_region = player_skin.regions[part][player_skin.current_region[part]]
	tween.interpolate_property(sprite, "region_rect:position", sprite.region_rect.position, target_region, 0.4, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
	tween.start()


func set_sprite_region(part: String, delta: int):
	var region_index = player_skin.current_region[part]
	region_index = posmod(region_index + delta, player_skin.regions[part].size())
	player_skin.set_part_region(part, region_index)
	update_ui(part)
