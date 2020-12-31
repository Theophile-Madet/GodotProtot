extends Area2D

const SPEED = 800

var main
var provoker: Node2D
var target: Node2D
var direction: Vector2

enum ProvokerSpearState {
	AIMING,
	THROWN,
}
var current_state = ProvokerSpearState.AIMING


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
			position += direction * delta * SPEED


func throw():
	current_state = ProvokerSpearState.THROWN
	direction = (target.position - self.position).normalized()
	
	
func on_body_touched(body: RigidBody2D):
	body.hit(1)
	queue_free()


func on_provoker_exit():
	if current_state == ProvokerSpearState.AIMING:
		queue_free()
		set_process(false)
