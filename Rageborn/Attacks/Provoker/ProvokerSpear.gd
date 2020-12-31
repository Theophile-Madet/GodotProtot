extends Area2D

const START_SPEED = 1000

var main
var provoker: Node2D
var target: Node2D
var direction: Vector2
var current_speed: float = START_SPEED

enum ProvokerSpearState {
	AIMING,
	THROWN,
}
var current_state = ProvokerSpearState.AIMING

var throw_sound_1 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound1.tscn")
var throw_sound_2 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound2.tscn")
var throw_sound_3 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound3.tscn")
var throw_sound_4 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound4.tscn")
var throw_sound_5 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound5.tscn")
var throw_sound_6 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound6.tscn")
var throw_sound_7 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound7.tscn")
var throw_sound_8 := preload("res://Rageborn/Attacks/Provoker/ThrowSounds/ProvokerThrowSound8.tscn")
var throw_sounds := [throw_sound_1, throw_sound_2, throw_sound_3, throw_sound_4, throw_sound_5, throw_sound_6, throw_sound_7, throw_sound_8]

func init(_provoker):
	provoker = _provoker
	main = provoker.main
	main.add_child(self)
	
	
	
func _ready():
	global_position = provoker.global_position
	target = provoker.targets_in_range[randi() % provoker.targets_in_range.size()]
	look_at(target.position)
	connect("body_entered", self, "on_body_touched")
	provoker.connect("tree_exiting", self, "on_provoker_exit")
	
	get_tree().create_timer(1).connect("timeout", self, "throw")
	get_tree().create_timer(5).connect("timeout", self, "queue_free")


func _process(delta: float):
	match current_state:
		ProvokerSpearState.AIMING:
			look_at(target.position)
			global_position = provoker.global_position
		ProvokerSpearState.THROWN:
			if current_speed >= 0:
				position += direction * delta * current_speed
				if current_speed <= 2:
					get_tree().create_timer(0.5).connect("timeout", self, "queue_free")
					monitoring = false


func throw():
	current_state = ProvokerSpearState.THROWN
	direction = (target.position - self.position).normalized()
	var sound = throw_sounds[randi() % throw_sounds.size()]
	main.play_sound(sound, position, 0)
	
	var tween := Tween.new()
	tween.interpolate_property(self, "current_speed", START_SPEED, 0, 2, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	add_child(tween)
	tween.start()
	
	
func on_body_touched(body: RigidBody2D):
	body.hit(1)
	queue_free()


func on_provoker_exit():
	if current_state == ProvokerSpearState.AIMING:
		queue_free()
		set_process(false)
