extends Area2D

var rageborne : Node2D
var main
var touched : Array

func init(rageborne : Node2D):
	rageborne = rageborne
	main = rageborne.main
	rageborne.add_child(self)
	
	
func _ready():
	connect("body_entered", self, "on_player_touched")
	var players = main.players
	var target : Node2D = players[randi() % players.size()]
	rotation = (target.global_position - global_position).angle() - PI / 2
	touched = []
	
	var tween = Tween.new()
	tween.interpolate_property(self, "scale:x", 0, 0.1, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	
	tween = Tween.new()
	var viewport_size = max(main.viewport_size.x, main.viewport_size.y)
	var target_scale =  viewport_size / $Sprite.get_rect().size.y 
	tween.interpolate_property(self, "scale:y", 0, target_scale, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
	add_child(tween)
	tween.start()

	tween = Tween.new()
	tween.interpolate_property(self, "scale:x", 0.1, 1, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN, 1)
	add_child(tween)
	tween.start()
	
	tween = Tween.new()
	tween.interpolate_property(self, "scale:x", 1, 0, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN, 2)
	add_child(tween)
	tween.start()
	
	var timer = Timer.new()
	timer.wait_time = 2.5
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, "queue_free")
	
	timer = Timer.new()
	timer.wait_time = 1
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, "enable_monitoring")
	monitoring = false
	
	timer = Timer.new()
	timer.wait_time = 2
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, "disable_monitoring")
	monitoring = false
	
	
func enable_monitoring():
	monitoring = true
	
	
func disable_monitoring():
	monitoring = false


func on_player_touched(player: Player):
	if player in touched:
		return
	player.hit(4)
	touched.append(player)
	

func _exit_tree():
	pass
	
