extends Node2D


var target


func init(_target):
	target = _target
	target.add_buff(self)
	target.add_child(self)


func _ready():
	get_tree().create_timer(3).connect("timeout",  self, "queue_free")
	$AudioStreamPlayer2D.pitch_scale = 0.75 + randf() * 0.5
	$AudioStreamPlayer2D.play()
	
	
func _exit_tree():
	target.remove_buff(self)
	
	
func modify_speed(speed: float):
	speed = 0
	return speed
