extends ColorRect

var target : Node2D


func init(_target : Node2D):
	target = _target


func _ready():
	rect_position.x = - rect_size.x / 2
	rect_position.y = - (target.SIZE / 2 + rect_size.y + 2)
	
	
func _process(_delta):
	$HP.max_value = target.get_max_hp()
	rect_size.x = max($HP.max_value * 4, 10)
	rect_position.x = - rect_size.x / 2
	$HP.value = target.get_current_hp()
