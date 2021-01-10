extends RigidBody2D

class_name BloodCry

const SIZE := 64
const CHARGE_TIME := 20

const TWEEN_X_DURATION = 1.6
const TWEEN_Y_DURATION = 2.1

enum BloodCryState {
	CHARGING,
	CASTING,
}
var current_state = BloodCryState.CHARGING

const MAX_HP:= 4
var hp: float = MAX_HP


var projectile_scene: PackedScene = preload("res://Rageborn/Attacks/BloodCry/BloodCryProjectile.tscn")

func init(rageborne):
	var spawn_position := Vector2()
	spawn_position.x = 75 + (Main.viewport_size.x - 150) * randf()
	spawn_position.y = 175 + (Main.viewport_size.y / 2.2) * randf()
	position = spawn_position
	Main.add_child(self)
	scale = Vector2.ZERO
	Main.add_hp_bar(self)
	Main.enemies.append(self)


func _ready():
	var tween := Tween.new()
	tween.interpolate_property($TextureProgress, "value", 
			0, $TextureProgress.max_value, CHARGE_TIME, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	
	tween = Tween.new()
	tween.interpolate_property(self, "scale", 
			Vector2.ZERO, Vector2.ONE, CHARGE_TIME / 2, 
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	
	get_tree().create_timer(CHARGE_TIME + 1).connect("timeout", self, "queue_free")
	for delay in [0, 0.25, 0.5, 0.75]:
		get_tree().create_timer(CHARGE_TIME + delay).connect("timeout", self, "shoot")
	
	var timer := Timer.new()
	timer.wait_time = TWEEN_X_DURATION
	timer.connect("timeout", self, "tween_background_x")
	timer.one_shot = false
	self.add_child(timer)
	timer.start()
	tween_background_x()
	
	timer = Timer.new()
	timer.wait_time = TWEEN_Y_DURATION
	timer.connect("timeout", self, "tween_background_y")
	timer.one_shot = false
	self.add_child(timer)
	timer.start()
	tween_background_y()
	

func tween_background_x():
	var tween := Tween.new()
	tween.remove($Background, "position:x")
	tween.interpolate_property($Background, "position:x", 
			$Background.position.x, rand_range(-8, 8), 
			TWEEN_X_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	

func tween_background_y():
	var tween := Tween.new()
	tween.remove($Background, "position:y")
	tween.interpolate_property($Background, "position:y", 
			$Background.position.y, rand_range(-8, 8), 
			TWEEN_Y_DURATION, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	
	
func shoot():
	var projectile = projectile_scene.instance()
	projectile.init(self)
	
	
func get_current_hp():
	return self.hp
	

func get_max_hp():
	return MAX_HP


func hit(damage: float) -> float:
	var hp_before = hp
	hp -= damage
	var overkill_damage = -hp
	Main.show_damage_number(hp - hp_before, global_position)
	if hp <= 0:
		queue_free()
	return overkill_damage

		
func add_buff(buff):
	pass


func _exit_tree():
	Main.enemies.erase(self)
