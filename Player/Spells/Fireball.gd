extends Area2D

const MAX_CHARGE := 3
const SPEED := 800
var input_action: String

var current_charge : float
var player : Node2D
var direction: Vector2
var has_hit_enemy: bool
var main

var sound_cast: PackedScene = preload("res://Player/Spells/FireballSoundCast.tscn")
var sound_hit: PackedScene = preload("res://Player/Spells/FireballSoundHit.tscn")

enum FireballState {
	CHARGING,
	CASTED,
}
var current_state


func init(_player):
	player = _player
	main = player.main
	main.add_child(self)


func _ready():
	current_charge = player.BACKSWING_DURATION
	current_state = FireballState.CHARGING
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	connect("body_entered", self, "enemy_hit")
	connect("area_entered", self, "enemy_projectile_hit")
	scale = Vector2(0 , 0)
	has_hit_enemy = false
	input_action = "player_%s_rune_right" % player.player_index
	$SoundCharge.play()


func _process(delta: float):
	rotate(delta)
	if current_state != FireballState.CASTED:
		return
	position += direction * delta * SPEED
	rotate(delta * 10)
	
	
func charge(delta: float):
	direction = player.current_look_direction
	global_position = player.global_position + direction.normalized() * player.SIZE
	current_charge += delta
	var charge_ratio := current_charge / MAX_CHARGE
	scale = Vector2.ONE * charge_ratio * 0.5
	$Particles2D.emitting = charge_ratio > 0.5
	$Particles2D.process_material.scale = charge_ratio * 0.1
	if current_charge >= MAX_CHARGE:
		cast()
		
		
func cast():
	player.start_backswing()
	current_state = FireballState.CASTED
	monitoring = true
	main.play_sound(sound_cast, position, get_sound_volume())
	$SoundCharge.stop()
	
	
func enemy_hit(enemy: Node):
	if has_hit_enemy:
		return
	enemy.hit(current_charge)
	queue_free()
	has_hit_enemy = true
	main.play_sound(sound_hit, position, get_sound_volume())
	
	
	
func enemy_projectile_hit(projectile: Area2D):
	if has_hit_enemy:
		return
	projectile.queue_free()
	queue_free()
	has_hit_enemy = true
	main.play_sound(sound_hit, position, get_sound_volume())


func get_sound_volume():
	return -12 * (1 - (current_charge / MAX_CHARGE))
