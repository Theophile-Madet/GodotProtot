extends Node2D

class_name Player

const SPEED: float = 400.0
var sprite_size : Vector2
onready var main = get_node("/root/Main")

const SIZE := 48
const MAX_HP = 10
var hp: float = MAX_HP / 2
var current_look_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2
var current_spell: Node2D
var current_charge_particle: Node2D
var current_cast_particle: Node2D
var player_index: int
var voice: String
var voice_max_index: int

const BACKSWING_DURATION = 0.5
const fireball_scene : PackedScene = preload("Spells/Fireball/Fireball.tscn")
const feral_lightning_scene : PackedScene = preload("Spells/FeralLightning/FeralLightning.tscn")
const heal_scene : PackedScene = preload("Spells/Heal/Heal.tscn")

var body_regions := []
var armor_regions := []
var legs_regions := []
var head_regions := []

enum PlayerState {
	MOVING,
	CASTING, 
	BACKSWING, 
	DAMAGE_ANIM, 
}
var current_state
	

func init(_player_index: int):
	player_index = _player_index
	build_sprite_regions()
	

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
	
	
func _ready():
	sprite_size = $Body.region_rect.size
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y * 3 / 4
	main.players.append(self)
	main.add_hp_bar(self)
	current_state = PlayerState.MOVING
	randomize_sprite($Body, body_regions)
	randomize_sprite($Body/Armor, armor_regions)
	randomize_sprite($Body/Legs, legs_regions)
	randomize_sprite($Body/Head, head_regions)
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
	
func _process(delta: float):
	update_look_direction()
	if current_state == PlayerState.MOVING:
		do_movement(delta)
	if current_state == PlayerState.MOVING or current_state == PlayerState.CASTING:
		do_spells(delta)
	if Input.is_action_just_pressed("player_%s_randomize_skin" % player_index):
		randomize_sprite($Body, body_regions)
		randomize_sprite($Body/Armor, armor_regions)
		randomize_sprite($Body/Legs, legs_regions)
		randomize_sprite($Body/Head, head_regions)
	

func update_look_direction():
	var new_direction = Vector2()
	if Input.is_action_pressed("player_%s_right" % player_index):
		new_direction.x += 1
	if Input.is_action_pressed("player_%s_left" % player_index):
		new_direction.x -= 1
	if Input.is_action_pressed("player_%s_down" % player_index):
		new_direction.y += 1
	if Input.is_action_pressed("player_%s_up" % player_index):
		new_direction.y -= 1
		
	current_move_direction = new_direction
	if new_direction != Vector2.ZERO:
		current_look_direction = new_direction.normalized()
	
	
func do_movement(delta: float):
	if current_state != PlayerState.MOVING:
		return
	
	if current_move_direction.length() <= 0:
		return
	
	var velocity := current_move_direction.normalized() * SPEED
	position += velocity * delta
	position.x = clamp(position.x, sprite_size.x / 2, main.viewport_size.x - sprite_size.x / 2)
	position.y = clamp(position.y, sprite_size.y / 2, main.viewport_size.y - sprite_size.y / 2)

		
func do_spells(delta: float):
	if current_state == PlayerState.CASTING:
		if Input.is_action_just_released(current_spell.input_action):
			current_spell.cast()
		else:
			current_spell.charge(delta)
			current_charge_particle.rotation = current_look_direction.angle()
			current_cast_particle.rotation = current_look_direction.angle()
	elif current_state == PlayerState.MOVING:
		if Input.is_action_just_pressed("player_%s_rune_right" % player_index):
			start_fireball()	
		if Input.is_action_just_pressed("player_%s_rune_top" % player_index):
			start_feral_lightning()
		if Input.is_action_just_pressed("player_%s_rune_bottom" % player_index):
			start_heal()	
	
	
func start_fireball():
	current_state = PlayerState.CASTING
	var fireball = fireball_scene.instance()
	current_spell = fireball
	fireball.init(self)
	current_charge_particle = $ParticlesRuneRedCharge
	current_cast_particle = $ParticlesRuneRedCast
	current_charge_particle.emitting = true
	current_charge_particle.amount = 5
	
	
func start_heal():
	current_state = PlayerState.CASTING
	var heal = heal_scene.instance()
	current_spell = heal
	heal.init(self)
	current_charge_particle = $ParticlesRuneGreenCharge
	current_cast_particle = $ParticlesRuneGreenCast
	current_charge_particle.emitting = true
	current_charge_particle.amount = 5
	

func start_feral_lightning():
	current_state = PlayerState.CASTING
	var lightning = feral_lightning_scene.instance()
	current_spell = lightning
	lightning.init(self)
	current_charge_particle = $ParticlesRuneYellowCharge
	current_cast_particle = $ParticlesRuneYellowCast
	current_charge_particle.emitting = true
	current_charge_particle.amount = 5
	
	
func start_backswing():
	current_charge_particle.emitting = false
	current_cast_particle.amount = max(1, 20 * (current_spell.current_charge / current_spell.MAX_CHARGE))
	current_cast_particle.emitting = true
	current_spell = null
	current_state = PlayerState.BACKSWING
	get_tree().create_timer(BACKSWING_DURATION).connect("timeout", self, "end_backswing")
	

func end_backswing():
	if current_state == PlayerState.BACKSWING:
		current_state = PlayerState.MOVING
	
	
func hit(damage: float):
	hp -= damage
	hp = clamp(hp, 0, MAX_HP)
	if damage > 0:
		var index = (randi() % voice_max_index) + 1
		var path := "res://Player/Sounds/%sHurt/S-%s.wav" % [voice, index]	
		main.play_sound_from_file(path, position, 0)
	

func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP

