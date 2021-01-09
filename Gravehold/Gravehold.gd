extends RigidBody2D

class_name Gravehold

const SIZE := 300
const MAX_HP := 60
var hp: float = MAX_HP

onready var main = get_node("/root/Main")

func _ready():
	position.x = main.viewport_size.x / 2
	position.y = main.viewport_size.y
	main.add_hp_bar(self)


func get_current_hp():
	return self.hp
	

func get_max_hp():
	return MAX_HP


func hit(damage: float):
	var hp_before = hp
	hp -= damage
	main.show_damage_number(hp - hp_before, global_position)
	if hp <= 0:
		main.add_child(load("res://LooseScene.tscn").instance())
