extends Area2D

const MAX_CHARGE := 2
const SPEED := 800
var input_action: String

var current_charge : float
var player : Node2D
var current_direction: Vector2
var has_hit_player: bool
var main
var target: Node2D = null

var sound_cast: PackedScene = preload("HealSoundCast.tscn")
var sound_hit: PackedScene = preload("HealSoundHit.tscn")

enum HealState {
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
	current_state = HealState.CHARGING
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	connect("body_entered", self, "player_hit")
	scale = Vector2(0 , 0)
	has_hit_player = false
	input_action = "player_%s_rune_bottom" % player.player_index
	$SoundCharge.play()


func _process(delta: float):
	rotate(delta)
	if current_state != HealState.CASTED:
		return
	update_target()
	if target != null:
		var target_direction = (target.global_position - global_position).normalized()
		current_direction = lerp(current_direction, target_direction, delta * 2).normalized()
	position += current_direction * delta * SPEED
	rotate(delta * 10)
	
	
func update_target():
	target = null
	var min_distance = INF
	for player in main.players:
		if player == self.player:
			continue
		var direction_to_player: Vector2 = player.global_position - global_position
		var angle = abs(current_direction.angle_to(direction_to_player))
		if angle > PI / 2:
			continue
		var distance = global_position.distance_squared_to(player.global_position)
		if distance > min_distance:
			continue
		min_distance = distance
		target = player
		
	
func charge(delta: float):
	current_direction = player.current_look_direction
	global_position = player.global_position + current_direction.normalized() * player.SIZE
	current_charge += delta
	var charge_ratio := current_charge / MAX_CHARGE
	scale = Vector2.ONE * charge_ratio * 0.5
	$Particles2D.emitting = charge_ratio > 0.5
	$Particles2D.process_material.scale = charge_ratio * 0.1
	if current_charge >= MAX_CHARGE:
		cast()
		
		
func cast():
	player.start_backswing()
	current_state = HealState.CASTED
	monitoring = true
	main.play_sound(sound_cast, position, get_sound_volume())
	$SoundCharge.stop()
	
	
func player_hit(player: RigidBody2D):
	if has_hit_player:
		return
	player.hit(-current_charge * 2)
	queue_free()
	has_hit_player = true
	main.play_sound(sound_hit, position, get_sound_volume())


func get_sound_volume() -> float:
	return -12 * (1 - (current_charge / MAX_CHARGE))
