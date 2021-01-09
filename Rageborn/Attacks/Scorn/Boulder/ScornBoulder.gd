extends Area2D

const SPEED = 100

var main
const direction := Vector2.DOWN 
var hit_sound := preload("ScornBoulderSoundHit.tscn")


func init(scorn):
	main = scorn.main
	global_position = scorn.global_position
	main.add_child(self)
	
	
func _ready():
	connect("body_entered", self, "on_body_touched")
	$VisibilityNotifier2D.connect("screen_exited", self, "queue_free")


func _process(delta: float):
	position += direction * delta * SPEED
	rotation += PI * delta
	
	
func on_body_touched(body: RigidBody2D):
	body.hit(3)
	main.play_sound(hit_sound,  position, 0, 0.75 + randf() * 0.5)
	queue_free()
