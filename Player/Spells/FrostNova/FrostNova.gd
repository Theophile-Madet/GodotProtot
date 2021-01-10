extends Area2D

const MAX_CHARGE := 1
var input_action: String

var current_charge : float
var player : Node2D
var direction: Vector2
var enemies_in_range: Array

var sound_cast: PackedScene = preload("FrostNovaSoundCast.tscn")
var buff_scene := preload("FrostNovaBuff.tscn")

enum FrostNovaState {
	CHARGING,
	CASTED,
}
var current_state


func init(_player):
	player = _player
	Main.add_child(self)


func _ready():
	current_charge = player.BACKSWING_DURATION
	current_state = FrostNovaState.CHARGING
	connect("body_entered", self, "enemy_entered")
	connect("body_exited", self, "enemy_exited")
#	connect("area_entered", self, "enemy_projectile_hit")
	scale = Vector2(0 , 0)
	input_action = "player_%s_rune_left" % player.player_index
	$SoundCharge.play()
	
	
func charge(delta: float):
	direction = player.current_look_direction
	rotation = direction.angle()
	global_position = player.global_position + direction.normalized() * player.SIZE * 0.5
	current_charge += delta
	var charge_ratio := current_charge / MAX_CHARGE
	scale = Vector2.ONE * charge_ratio
	if current_charge >= MAX_CHARGE:
		cast()
		
		
func cast():
	player.start_backswing()
	current_state = FrostNovaState.CASTED
	monitoring = true
	Main.play_sound(sound_cast, position, get_sound_volume())
	$SoundCharge.stop()
	for enemy in enemies_in_range:
		var direction_to_enemy = enemy.global_position - global_position
		if abs(direction.angle_to(direction_to_enemy)) > PI / 4:
			continue
		var buff = buff_scene.instance()
		buff.init(enemy)
	queue_free()
	
	
func enemy_entered(enemy: Node):
	enemies_in_range.append(enemy)
	
	
func enemy_exited(enemy: Node):
	enemies_in_range.erase(enemy)


func get_sound_volume() -> float:
	return -12 * (1 - (current_charge / MAX_CHARGE))
