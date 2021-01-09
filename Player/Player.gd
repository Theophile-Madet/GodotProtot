extends Node2D

class_name Player


const SPEED: float = 400.0
var sprite_size : Vector2
onready var main = get_node("/root/Main")

const SIZE := 48
const MAX_HP = 20
var hp: float = MAX_HP
var current_look_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2
var current_spell: Node2D
var current_charge_particle: Node2D
var current_cast_particle: Node2D
var player_index: int
var skin


const BACKSWING_DURATION = 0.01
const fireball_scene : PackedScene = preload("Spells/Fireball/Fireball.tscn")
const feral_lightning_scene : PackedScene = preload("Spells/FeralLightning/FeralLightning.tscn")
const heal_scene : PackedScene = preload("Spells/Heal/Heal.tscn")
const frost_nova_scene : PackedScene = preload("Spells/FrostNova/FrostNova.tscn")

const skin_choice_scene : PackedScene = preload("SkinChoiceUI/SkinChoiceUI.tscn")
var skin_choice_ui: Control

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
	sprite_size = $PlayerSkin/Body.region_rect.size
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y * 3 / 4
	main.players.append(self)
	main.add_hp_bar(self)
	current_state = PlayerState.MOVING
	skin = $PlayerSkin
	skin.init(self)
	main.connect("game_state_changed", self, "on_game_state_changed")
	skin_choice_ui = skin_choice_scene.instance()
	skin_choice_ui.init(self)
	on_game_state_changed(main.game_state)
	
	
func _process(delta: float):
	if main.game_state == GameState.GameState.CHOOSE_SKIN:
		return
		
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
			current_charge_particle.rotation = current_look_direction.angle()
			current_cast_particle.rotation = current_look_direction.angle()
	elif current_state == PlayerState.MOVING:
		if Input.is_action_just_pressed("player_%s_rune_right" % player_index):
			start_fireball()	
		if Input.is_action_just_pressed("player_%s_rune_top" % player_index):
			start_feral_lightning()
		if Input.is_action_just_pressed("player_%s_rune_bottom" % player_index):
			start_heal()	
		if Input.is_action_just_pressed("player_%s_rune_left" % player_index):
			start_frost_nova()
	
	
func start_fireball():
	current_state = PlayerState.CASTING
	var fireball = fireball_scene.instance()
	current_spell = fireball
	fireball.init(self)
	current_charge_particle = $ParticlesRuneRedCharge
	current_cast_particle = $ParticlesRuneRedCast
	current_charge_particle.emitting = true
	
	
func start_heal():
	current_state = PlayerState.CASTING
	var heal = heal_scene.instance()
	current_spell = heal
	heal.init(self)
	current_charge_particle = $ParticlesRuneGreenCharge
	current_cast_particle = $ParticlesRuneGreenCast
	current_charge_particle.emitting = true
	

func start_feral_lightning():
	current_state = PlayerState.CASTING
	var lightning = feral_lightning_scene.instance()
	current_spell = lightning
	lightning.init(self)
	current_charge_particle = $ParticlesRuneYellowCharge
	current_cast_particle = $ParticlesRuneYellowCast
	current_charge_particle.emitting = true
	
	
func start_frost_nova():
	current_state = PlayerState.CASTING
	var nova = frost_nova_scene.instance()
	current_spell = nova
	nova.init(self)
	current_charge_particle = $ParticlesRuneBlueCharge
	current_cast_particle = $ParticlesRuneBlueCast
	current_charge_particle.emitting = true
	
	
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
	var hp_before = hp
	hp -= damage
	main.show_damage_number(hp - hp_before, global_position)
	if hp < 0 :
		main.gravehold.hit(-hp * 2)
	hp = clamp(hp, 0, MAX_HP)
	if damage > 0:
		skin.play_hit_sound()
	

func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP


func on_game_state_changed(new_state):
	match new_state:
		GameState.GameState.CHOOSE_SKIN:
			$PlayerSkin.scale = Vector2.ONE * 2
			set_ui_position()
			skin_choice_ui.visible = true
		_:
			$PlayerSkin.scale = Vector2.ONE * 1
			skin_choice_ui.visible = false


func set_ui_position():
	var x_pos = main.viewport_size.x / 4
	if player_index == 2 or player_index == 4:
		x_pos *= 3
	var y_pos = main.viewport_size.y / 4
	if player_index == 3 or player_index == 4:
		y_pos *= 3
	global_position = Vector2(x_pos, y_pos)
