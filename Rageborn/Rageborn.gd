extends Node2D

const SIZE := 60
const ATTACK_COOLDOWN := 5
var time_since_last_attack: float = ATTACK_COOLDOWN - 0.5

onready var main = get_node("/root/Main")

var laser_scene: PackedScene = preload("Attacks/Laser/Laser.tscn")
var provoker_scene: PackedScene = preload("Attacks/Provoker/Provoker.tscn")
var bloodcry_scene: PackedScene = preload("Attacks/BloodCry/BloodCry.tscn")
var scorn_scene: PackedScene = preload("Attacks/Scorn/Scorn.tscn")
#var attack_scenes = [laser_scene, provoker_scene, bloodcry_scene, scorn_scene]
var attack_scenes = [provoker_scene, scorn_scene]

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
	var attack = attack_scenes[randi() % attack_scenes.size()]
	attack.instance().init(self)

	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	hp -= damage
