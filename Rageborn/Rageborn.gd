extends Node2D

const SIZE := 60
const ATTACK_COOLDOWN := 20
var time_since_last_attack: float = ATTACK_COOLDOWN - 2

onready var main = get_node("/root/Main")

#Attacks
var laser_scene: PackedScene = preload("Attacks/Laser.tscn")
var provoker_scene: PackedScene = preload("Attacks/Provoker/Provoker.tscn")

var MAX_HP := 50
var hp

	
func _ready():
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y / 10
	hp = MAX_HP
	main.add_hp_bar(self)


func _process(delta: float):
	time_since_last_attack += delta
	
	if time_since_last_attack > ATTACK_COOLDOWN:
		time_since_last_attack -= ATTACK_COOLDOWN
		attack()


func attack():
	var attack = randi() % 2
	match attack:
		0:
			cast_laser()
		1:
			cast_provoker()


func cast_laser():
	var laser = laser_scene.instance()
	laser.init(self)
	
	
func cast_provoker():
	var provoker = provoker_scene.instance()
	provoker.init(self)
	
	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	hp -= damage
