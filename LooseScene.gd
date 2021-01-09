extends Control


func _ready():
	var viewport_size = get_node("/root/Main").viewport_size
	self.rect_position = viewport_size / 2
