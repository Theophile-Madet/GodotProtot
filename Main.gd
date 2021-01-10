extends Node2D

const Global = preload("res://GameState.gd")

var viewport_size : Vector2
var players : Array
var damage_number_scene := preload("res://DamageNumber.tscn")
var hp_bar_scene := preload("res://HPBAR/HPBar.tscn")
var player_scene := preload("Player/Player.tscn")
var rageborn_scene = preload("Rageborn/Rageborn.tscn")
var tile_map_scene = preload("TileMap/TileMap.tscn")
var gravehold_scene = preload("res://Gravehold/Gravehold.tscn")
var gravehold
var game_state
var rageborne = null

signal game_state_changed(new_state)

	
func _ready():
	randomize()
	viewport_size = get_viewport_rect().size
	game_state = GameState.GameState.CHOOSE_SKIN
	
	
	add_child(tile_map_scene.instance())
	gravehold = gravehold_scene.instance()
	add_child(gravehold)
	
	create_input_map()
	create_player(1)

	
func _process(delta: float):
	if Input.is_action_just_pressed("start_rageborne"):
		if game_state == GameState.GameState.CHOOSE_SKIN:
			game_state = GameState.GameState.PREPARE
			emit_signal("game_state_changed", game_state)
		elif game_state == GameState.GameState.PREPARE:
			game_state = GameState.GameState.FIGHT
			add_child(rageborn_scene.instance())
			emit_signal("game_state_changed", game_state)
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
	
	
func play_sound(scene: PackedScene, position: Vector2, volume_db: float, pitch_scale: float = 1) -> AudioStreamPlayer2D:
	var sound = (scene.instance() as AudioStreamPlayer2D)
	add_child(sound)
	sound.volume_db = volume_db
	sound.position = position
	sound.connect("finished", sound, "queue_free")
	sound.pitch_scale = pitch_scale
	sound.play()
	return sound


func play_sound_from_file(path: String, position: Vector2, volume_db: float, pitch_scale: float = 1) -> AudioStreamPlayer2D:
	var sound := AudioStreamPlayer2D.new()
	var sound_file: AudioStream = load(path)
	sound.stream = sound_file
	add_child(sound)
	sound.volume_db = volume_db
	sound.position = position
	sound.connect("finished", sound, "queue_free")
	sound.pitch_scale = pitch_scale
	sound.play()
	return sound


func create_input_map():
	create_input_action_keyboard("player_1_rune_left", KEY_KP_4)
	create_input_action_keyboard("player_1_rune_right", KEY_KP_6)
	create_input_action_keyboard("player_1_rune_top", KEY_KP_8)
	create_input_action_keyboard("player_1_rune_bottom", KEY_KP_5)
	create_input_action_keyboard("player_1_start", KEY_ENTER)
	create_input_action_keyboard("player_1_left", KEY_A)
	create_input_action_keyboard("player_1_right", KEY_D)
	create_input_action_keyboard("player_1_up", KEY_W)
	create_input_action_keyboard("player_1_down", KEY_S)
	create_input_action_keyboard("player_1_skin_Body_left", KEY_Z)
	create_input_action_keyboard("player_1_skin_Body_right", KEY_U)
	create_input_action_keyboard("player_1_skin_Head_left", KEY_H)
	create_input_action_keyboard("player_1_skin_Head_right", KEY_J)
	create_input_action_keyboard("player_1_skin_Torso_left", KEY_I)
	create_input_action_keyboard("player_1_skin_Torso_right", KEY_O)
	create_input_action_keyboard("player_1_skin_Legs_left", KEY_K)
	create_input_action_keyboard("player_1_skin_Legs_right", KEY_L)
	
	create_input_action_joypad_button("player_%s_rune_left", JOY_XBOX_X)
	create_input_action_joypad_button("player_%s_rune_right", JOY_XBOX_B)
	create_input_action_joypad_button("player_%s_rune_top", JOY_XBOX_Y)
	create_input_action_joypad_button("player_%s_rune_bottom", JOY_XBOX_A)
	
	create_input_action_joypad_button("player_%s_start", JOY_START)
	
	create_input_action_joypad_axis("player_%s_left", JOY_ANALOG_LX, -1)
	create_input_action_joypad_axis("player_%s_right", JOY_ANALOG_LX, 1)
	create_input_action_joypad_axis("player_%s_up", JOY_ANALOG_LY, -1)
	create_input_action_joypad_axis("player_%s_down", JOY_ANALOG_LY, 1)
	
	create_input_action_joypad_button("player_%s_left", JOY_DPAD_LEFT)
	create_input_action_joypad_button("player_%s_right", JOY_DPAD_RIGHT)
	create_input_action_joypad_button("player_%s_up", JOY_DPAD_UP)
	create_input_action_joypad_button("player_%s_down", JOY_DPAD_DOWN)
	
	create_input_action_joypad_axis("player_%s_skin_Body_left", JOY_ANALOG_LX, -1)
	create_input_action_joypad_axis("player_%s_skin_Body_right", JOY_ANALOG_LX, 1)
	create_input_action_joypad_axis("player_%s_skin_Head_left", JOY_ANALOG_RX, -1)
	create_input_action_joypad_axis("player_%s_skin_Head_right", JOY_ANALOG_RX, 1)
	create_input_action_joypad_button("player_%s_skin_Torso_left", JOY_DPAD_LEFT)
	create_input_action_joypad_button("player_%s_skin_Torso_right", JOY_DPAD_RIGHT)
	create_input_action_joypad_button("player_%s_skin_Legs_left", JOY_XBOX_X)
	create_input_action_joypad_button("player_%s_skin_Legs_right", JOY_XBOX_B)
	
	
static func create_input_action_keyboard(action: String, key: int):
	create_action_if_necessary(action)
	var event := InputEventKey.new()
	event.scancode = key
	InputMap.action_add_event(action, event)
	
	
static func create_input_action_joypad_button(action_base: String, button_index: int):
	for player_index in range(4):
		var action := action_base % (player_index + 1)
		create_action_if_necessary(action)
		var event := InputEventJoypadButton.new()
		event.device = player_index
		event.button_index = button_index
		InputMap.action_add_event(action, event)
		

static func create_input_action_joypad_axis(action_base: String, axis: int, axis_value: float):
	for player_index in range(4):
		var action := action_base % (player_index + 1)
		create_action_if_necessary(action)
		var event := InputEventJoypadMotion.new()
		event.device = player_index
		event.axis = axis
		event.axis_value = axis_value
		InputMap.action_add_event(action, event)
		

static func create_action_if_necessary(action: String):
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	
	
func show_damage_number(damage: float, global_position: Vector2):
	damage_number_scene.instance().init(self, damage, global_position)
