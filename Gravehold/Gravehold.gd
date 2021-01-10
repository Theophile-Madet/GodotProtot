extends RigidBody2D

class_name Gravehold

const SIZE := 300
const MAX_HP := 60
var hp: float = MAX_HP


func _ready():
	position.x = Main.viewport_size.x / 2
	position.y = Main.viewport_size.y
	Main.add_hp_bar(self)


func get_current_hp():
	return self.hp
	

func get_max_hp():
	return MAX_HP


func hit(damage: float):
	var hp_before = hp
	hp -= damage
	Main.show_damage_number(hp - hp_before, global_position)
	if hp <= 0:
		Main.add_child(load("res://LooseScene.tscn").instance())
