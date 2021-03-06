extends Area2D


const SPEED := 150
const STEERING := 2
var target: Node2D
var direction: Vector2


func init(bloodcry: Node2D):
	global_position = bloodcry.global_position
	var targets = Main.players.duplicate()
	targets.append(Main.gravehold)
	target = targets[randi() % targets.size()]
	look_at(target.global_position)
	direction = (target.global_position - global_position).normalized()
	Main.add_child(self)
	connect("body_entered", self, "on_body_touched")
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")


func _process(delta: float):
	direction = lerp(direction, (target.global_position - global_position).normalized(), delta * STEERING)
	direction = direction.normalized()
	rotation = direction.angle()
	position += direction * delta * SPEED


func on_body_touched(body: RigidBody2D):
	body.hit(3)
	queue_free()
