extends Node2D


var viewport_size : Vector2
var players : Array
var hp_bar_scene := preload("res://HPBAR/HPBar.tscn")
var player_scene := preload("Player/Player.tscn")
var gravehold

func _ready():
	randomize()
	viewport_size = get_viewport_rect().size
	
	var tile_map_scene = preload("TileMap/TileMap.tscn")
	add_child(tile_map_scene.instance())
	var rageborn_scene = preload("Rageborn/Rageborn.tscn")
	add_child(rageborn_scene.instance())
	var gravehold_scene = preload("res://Gravehold/Gravehold.tscn")
	gravehold = gravehold_scene.instance()
	add_child(gravehold)
	
	create_player(1)

	
func _process(delta: float):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	for index in [2, 3]:
		create_player_if_necessary(index)


func create_player_if_necessary(index: int):
	if Input.is_action_just_pressed("player_%s_start" % index):
		var player_exists := false
		for player in players:
			if player.player_index == index:
				player_exists = true
				break
		if not player_exists:
			create_player(index)


func create_player(index: int):
	var player = player_scene.instance()
	player.init(index)
	add_child(player)
			
	
func add_hp_bar(target: Node2D):
	var hpbar = hp_bar_scene.instance()
	hpbar.init(target)
	target.add_child(hpbar)
	
	
func play_sound(scene: PackedScene, position: Vector2, volume_db: float) -> AudioStreamPlayer2D:
	var sound = (scene.instance() as AudioStreamPlayer2D)
	add_child(sound)
	sound.volume_db = volume_db
	sound.position = position
	sound.connect("finished", sound, "queue_free")
	sound.play()
	return sound
