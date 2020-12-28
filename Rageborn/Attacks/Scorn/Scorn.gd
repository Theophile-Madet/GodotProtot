extends RigidBody2D

const SPEED = 0
const SIZE = 48


const MAX_HP:= 9
var hp: float = MAX_HP
var main
var boulder_scene: PackedScene = preload("res://Rageborn/Attacks/Scorn/ScornBoulder.tscn")
const ATTACK_COOLDOWN := 5
var time_since_last_attack: float = 0


func init(rageborne):
	main = rageborne.main
	main.add_child(self)
	var spawn_position := Vector2()
	spawn_position.x = 400 + (main.viewport_size.x - 800) * randf()
	spawn_position.y = 150 + (main.viewport_size.y / 2.5) * randf()
	global_position = spawn_position
	$Sprite.visible = false
	
	
func _ready():
	$Particles2D.emitting = true
	var timer := Timer.new()
	timer.wait_time = 2.4
	timer.connect("timeout", self, "spawn")
	add_child(timer)
	timer.start()
	layers = 0b0
	

func spawn():
	$Sprite.visible = true
	main.add_hp_bar(self)
	layers = 0b10
	
	
func _process(delta: float):
	time_since_last_attack += delta
	if time_since_last_attack > ATTACK_COOLDOWN:
		attack()
	
	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	hp -= damage
	if hp <= 0:
		queue_free()
		

func attack():
	time_since_last_attack -= ATTACK_COOLDOWN
	var boulder = boulder_scene.instance()
	boulder.init(self)
