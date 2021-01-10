extends AbstractSpell

const SPEED := 800

var direction: Vector2
var target: Node2D = null

var sound_hit: PackedScene = preload("FireballSoundHit.tscn")


func _ready():
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	connect("body_entered", self, "enemy_hit")
	connect("area_entered", self, "enemy_projectile_hit")


func _process(delta: float):
	rotate(delta)
	if current_state != SpellState.CASTED:
		return
	update_target()
	if target != null:
		var target_direction = (target.global_position - global_position).normalized()
		direction = lerp(direction, target_direction, delta).normalized()
	position += direction * delta * SPEED
	rotate(delta * 10)
	

func update_target():
	target = null
	var min_angle = INF
	for enemy in Main.enemies:
		var direction_to_enemy: Vector2 = enemy.global_position - global_position
		var angle = abs(direction.angle_to(direction_to_enemy))
		if angle > PI / 2:
			continue
		if angle > min_angle:
			continue
		min_angle = angle
		target = enemy


func charge_implementation():
	direction = player.current_look_direction
	global_position = player.global_position + direction.normalized() * player.SIZE
	update_scale()
	$Particles2D.process_material.scale = charge_ratio() * 0.1


func cast_implementation():
	monitoring = true
	
	
func update_scale():
	scale = Vector2.ONE * max(charge_ratio(), 0.1) * 0.5
	$Particles2D.emitting = charge_ratio() > 0.5

func enemy_hit(enemy: Node):
	if is_queued_for_deletion():
		return
	Main.play_sound(sound_hit, position, get_sound_volume())
	var overkill_damage = enemy.hit(current_charge)
	current_charge = overkill_damage
	if current_charge <= 0:
		queue_free()
		return
	update_scale()


func enemy_projectile_hit(projectile: Area2D):
	if is_queued_for_deletion():
		return
	projectile.queue_free()
	current_charge -= 1
	if current_charge <= 0:
		queue_free()
		return
	update_scale()
	Main.play_sound(sound_hit, position, get_sound_volume())

	
func sound_cast() -> PackedScene:
	return preload("FireballSoundCast.tscn")
func max_charge() -> float:
	return 3.0
func rune() -> String:
	return "right"
