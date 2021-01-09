extends Node2D

const SIZE := 60
const MINION_ATTACK_COOLDOWN := 5
var time_since_last_minion_attack: float = MINION_ATTACK_COOLDOWN - 5

const SPELL_ATTACK_COOLDOWN := 7
var time_since_last_spell_attack: float = MINION_ATTACK_COOLDOWN - 2

onready var main = get_node("/root/Main")

var buffs := []

var laser_scene: PackedScene = preload("Attacks/Laser/Laser.tscn")
var provoker_scene: PackedScene = preload("Attacks/Provoker/Provoker.tscn")
var bloodcry_scene: PackedScene = preload("Attacks/BloodCry/BloodCry.tscn")
var scorn_scene: PackedScene = preload("Attacks/Scorn/Scorn.tscn")
var minion_scenes = [provoker_scene, scorn_scene]
var spell_scenes = [laser_scene, bloodcry_scene]

var MAX_HP := 100
var hp

	
func _ready():
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y / 10
	hp = MAX_HP
	main.add_hp_bar(self)


func _process(delta: float):
	if hp <= 0:
		return
	time_since_last_minion_attack += delta
	if time_since_last_minion_attack > MINION_ATTACK_COOLDOWN:
		time_since_last_minion_attack -= MINION_ATTACK_COOLDOWN
		minion_attack()
		
	time_since_last_spell_attack += delta
	if time_since_last_spell_attack > SPELL_ATTACK_COOLDOWN:
		time_since_last_spell_attack -= SPELL_ATTACK_COOLDOWN
		spell_attack()


func minion_attack():
	var attack_scene = minion_scenes[randi() % minion_scenes.size()]
	
	var nb_attacks := 0
	match attack_scene:
		provoker_scene:
			nb_attacks = 8
		scorn_scene:
			nb_attacks = 2
			
	for i in range(nb_attacks):
		attack_scene.instance().init(self)
		

func spell_attack():
	var attack_scene = spell_scenes[randi() % spell_scenes.size()]
	
	var nb_attacks := 0
	match attack_scene:
		laser_scene:
			nb_attacks = randi() % main.players.size()
		bloodcry_scene:
			nb_attacks = 1
			
	for i in range(nb_attacks):
		attack_scene.instance().init(self)

	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	var hp_before = hp
	hp -= damage
	main.show_damage_number(hp - hp_before, global_position)
	hp = clamp(hp, 0, MAX_HP)
	if hp <= 0:
		main.add_child(load("res://WinScene.tscn").instance())
	

func add_buff(buff):
	buffs.append(buff)
	
	
func remove_buff(buff):
	buffs.erase(buff)
