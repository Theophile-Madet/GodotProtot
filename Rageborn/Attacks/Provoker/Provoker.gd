extends RigidBody2D

const SPEED = 30
const SIZE = 32
const RANGE = 256

enum ProvokerState {
	SPAWNING,
	MARCHING,
}
var current_state = ProvokerState.SPAWNING

const MAX_HP:= 5
var hp: float = MAX_HP
var main
var targets_in_range: Array = []
var spear_scene: PackedScene = preload("res://Rageborn/Attacks/Provoker/ProvokerSpear.tscn")
const ATTACK_COOLDOWN := 2
var time_since_last_attack: float = ATTACK_COOLDOWN


func init(rageborne):
	main = rageborne.main
	rageborne.add_child(self)
	var spawn_position = Vector2.RIGHT
	spawn_position *= 70 + 70 * randf()
	spawn_position = spawn_position.rotated(PI * randf())
	position = spawn_position
	
	
func _ready():
	$Particles2D.emitting = true
	$Sprite.visible = false
	var timer := Timer.new()
	timer.wait_time = 2.4
	timer.connect("timeout", self, "spawn")
	add_child(timer)
	timer.start()
	layers = 0b0
	

func spawn():
	$Sprite.visible = true
	current_state = ProvokerState.MARCHING
	main.add_hp_bar(self)
	layers = 0b10
	
	
func _process(delta: float):
	if current_state == ProvokerState.MARCHING:
		update_targets_in_range()
		do_movement(delta)
		do_attack(delta)
		

func update_targets_in_range():
	targets_in_range = []
	
	var gravehold_top = main.gravehold.global_position.y - main.gravehold.get_node("CollisionShape2D").shape.extents.y
	if global_position.y + RANGE >= gravehold_top:
		targets_in_range.append(main.gravehold)
	
	for player in main.players:
		if global_position.distance_to(player.global_position) < RANGE:
			targets_in_range.append(player)
	
	
func do_movement(delta: float):
	var factor = 1 if targets_in_range.size() == 0 else 0
	position += Vector2.DOWN * SPEED * delta * factor
	
	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	hp -= damage
	if hp <= 0:
		queue_free()
		

func do_attack(delta: float):
	if time_since_last_attack <= ATTACK_COOLDOWN:
		time_since_last_attack += delta
		
	if time_since_last_attack >= ATTACK_COOLDOWN and targets_in_range.size() > 0 :
		throw_spear()
	
	
func throw_spear():
	time_since_last_attack -= ATTACK_COOLDOWN
	var spear = spear_scene.instance()
	spear.init(self)
