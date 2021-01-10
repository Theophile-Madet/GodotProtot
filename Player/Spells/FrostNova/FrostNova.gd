extends AbstractSpell


var direction: Vector2
var enemies_in_range: Array

var buff_scene := preload("FrostNovaBuff.tscn")


func _ready():
	connect("body_entered", self, "enemy_entered")
	connect("body_exited", self, "enemy_exited")
	
	
func charge_implementation():
	direction = player.current_look_direction
	rotation = direction.angle()
	global_position = player.global_position + direction.normalized() * player.SIZE * 0.5
	scale = Vector2.ONE * charge_ratio()
		
		
func cast_implementation():
	monitoring = true
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


func sound_cast() -> PackedScene:
	return preload("FrostNovaSoundCast.tscn")
func max_charge() -> float:
	return 2.0
func rune() -> String:
	return "left"
