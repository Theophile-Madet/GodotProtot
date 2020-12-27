extends Node2D

class_name Player

const SPEED: float = 400.0
var sprite_size : Vector2
onready var main = get_node("/root/Main")

const SIZE := 32
const MAX_HP = 10
var hp: float = MAX_HP
var current_look_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2
var current_spell
var player_index: int

const BACKSWING_DURATION = 0.5
var fireball_scene : PackedScene = preload("res://Player/Spells/Fireball.tscn")

enum PlayerState {
	MOVING,
	CASTING, 
	BACKSWING, 
	DAMAGE_ANIM, 
}
var current_state
	

func init(_player_index: int):
	player_index = _player_index
	
	
func _ready():
	sprite_size = $Sprite.region_rect.size
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y * 3 / 4
	main.players.append(self)
	main.add_hp_bar(self)
	current_state = PlayerState.MOVING
	
	
func _process(delta: float):
	update_look_direction()
	if current_state == PlayerState.MOVING:
		do_movement(delta)
	if current_state == PlayerState.MOVING or current_state == PlayerState.CASTING:
		do_spells(delta)
	

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
			$ParticlesRuneRedCharge.rotation = current_look_direction.angle()
			$ParticlesRuneRedCast.rotation = current_look_direction.angle()
	elif current_state == PlayerState.MOVING:
		if Input.is_action_just_pressed("player_%s_rune_right" % player_index):
			start_fireball()	
	
	
func start_fireball():
	current_state = PlayerState.CASTING
	var fireball = fireball_scene.instance()
	current_spell = fireball
	fireball.init(self)
	main.add_child(fireball)
	$ParticlesRuneRedCharge.emitting = true
	$ParticlesRuneRedCharge.amount = 5
	
	
func start_backswing():
	$ParticlesRuneRedCharge.emitting = false
	$ParticlesRuneRedCast.amount = max(1, 20 * (current_spell.current_charge / current_spell.MAX_CHARGE))
	$ParticlesRuneRedCast.emitting = true
	current_spell = null
	current_state = PlayerState.BACKSWING
	var timer = Timer.new()
	timer.wait_time = BACKSWING_DURATION
	timer.connect("timeout", self, "end_backswing")
	timer.connect("timeout", timer, "queue_free")
	add_child(timer)
	timer.start()
	

func end_backswing():
	if current_state == PlayerState.BACKSWING:
		current_state = PlayerState.MOVING
	
	
func hit(damage: float):
	hp -= damage
	

func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP

