extends AbstractSpell

const SPEED := 800

var current_direction: Vector2
var target: Node2D = null

var sound_hit: PackedScene = preload("HealSoundHit.tscn")


func _ready():
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	connect("body_entered", self, "player_hit")


func _process(delta: float):
	rotate(delta)
	if current_state != SpellState.CASTED:
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
	for player in Main.players:
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
		
	
func charge_implementation():
	current_direction = player.current_look_direction
	global_position = player.global_position + current_direction.normalized() * player.SIZE
	scale = Vector2.ONE * charge_ratio() * 0.5
	$Particles2D.emitting = charge_ratio() > 0.5
	$Particles2D.process_material.scale = charge_ratio() * 0.1
		
		
func cast_implementation():
	monitoring = true
	
	
func player_hit(player: RigidBody2D):
	if is_queued_for_deletion():
		return
	player.hit(-current_charge * 4)
	queue_free()
	Main.play_sound(sound_hit, position, get_sound_volume())
	

func sound_cast() -> PackedScene:
	return preload("HealSoundCast.tscn")
func max_charge() -> float:
	return 2.0
func rune() -> String:
	return "bottom"
