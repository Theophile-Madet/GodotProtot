extends Area2D

const MAX_CHARGE := 3
const SPEED := 800
var input_action: String

var current_charge := 0.0
var player : Node2D
var direction: Vector2
var has_hit_enemy: bool
var added_charge := 0.0

var sound_cast: PackedScene = preload("FireballSoundCast.tscn")
var sound_hit: PackedScene = preload("FireballSoundHit.tscn")

enum FireballState {
	CHARGING,
	CASTED,
}
var current_state


func init(_player: Node2D):
	player = _player
	Main.add_child(self)


func _ready():
	current_state = FireballState.CHARGING
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	connect("body_entered", self, "enemy_hit")
	connect("area_entered", self, "enemy_projectile_hit")
	scale = Vector2(0 , 0)
	has_hit_enemy = false
	input_action = "player_%s_rune_right" % player.player_index
	$SoundCharge.play()
	charge(player.precharge, true)


func _process(delta: float):
	rotate(delta)
	if current_state != FireballState.CASTED:
		return
	position += direction * delta * SPEED
	rotate(delta * 10)
	
	
func charge(delta: float, is_precharge: bool):
	if is_precharge:
		current_charge = min(delta, MAX_CHARGE / 2)
	else:
		current_charge += delta * 2
	
	current_charge = min(current_charge, MAX_CHARGE)
	
	direction = player.current_look_direction
	global_position = player.global_position + direction.normalized() * player.SIZE
	var charge_ratio := current_charge / MAX_CHARGE
	scale = Vector2.ONE * max(charge_ratio, 0.1) * 0.5
	$Particles2D.emitting = charge_ratio > 0.5
	$Particles2D.process_material.scale = charge_ratio * 0.1
	if current_charge >= MAX_CHARGE:
		cast()
		
		
func cast():
	player.finish_casting()
	current_state = FireballState.CASTED
	monitoring = true
	Main.play_sound(sound_cast, position, get_sound_volume())
	$SoundCharge.stop()
	
	
func enemy_hit(enemy: Node):
	if has_hit_enemy:
		return
	enemy.hit(current_charge)
	queue_free()
	has_hit_enemy = true
	Main.play_sound(sound_hit, position, get_sound_volume())
	
	
	
func enemy_projectile_hit(projectile: Area2D):
	if has_hit_enemy:
		return
	projectile.queue_free()
	queue_free()
	has_hit_enemy = true
	Main.play_sound(sound_hit, position, get_sound_volume())


func get_sound_volume() -> float:
	return -12 * (1 - (current_charge / MAX_CHARGE))
