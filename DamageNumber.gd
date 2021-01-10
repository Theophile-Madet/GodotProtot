extends Node2D

var damage: float
var color: Color


func init(main, _damage: float, _global_position: Vector2):
	damage = _damage * 10
	if damage == 0:
		queue_free()
	global_position = _global_position
	Main.add_child(self)
	color = Color(0.8, 0, 0)
	if damage > 0:
		color = Color(0, 0.8, 0)
	$Label.set("custom_colors/font_color", color)
	

func _ready():
	$Label.text = "%+d" % damage
	get_tree().create_timer(1).connect("timeout", self, "queue_free")
	var tween := Tween.new()
	tween.interpolate_method(self, "set_color", 1, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
	add_child(tween)
	tween.start()
	

func _process(delta):
	position.y -= delta * 100


func set_color(alpha: float):
	color.a = alpha
	$Label.set("custom_colors/font_color", color)
	$Label.set("custom_colors/font_outline_modulate", Color(0, 0, 0, alpha))
