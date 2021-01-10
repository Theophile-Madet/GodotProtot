extends RigidBody2D

class_name Provoker

const SPEED = 30
const SIZE = 32
const RANGE = 256

enum ProvokerState {
	SPAWNING,
	MARCHING,
}
var current_state = ProvokerState.SPAWNING

const MAX_HP:= 1
var hp: float = MAX_HP
var targets_in_range: Array = []
var spear_scene: PackedScene = preload("res://Rageborn/Attacks/Provoker/ProvokerSpear.tscn")
const ATTACK_COOLDOWN := 2
var time_since_last_attack: float = ATTACK_COOLDOWN
var sound_pitch = 0.5 + randf()
var debug := false

var buffs := []

var summon_sound := preload("res://Rageborn/Attacks/SummonSound/SummonSound.tscn")
var death_sound_1 := preload("res://Rageborn/Attacks/Provoker/DeathSounds/ProvokerDeathSound1.tscn")
var death_sound_2 := preload("res://Rageborn/Attacks/Provoker/DeathSounds/ProvokerDeathSound2.tscn")
var death_sounds := [death_sound_1, death_sound_2]

var hit_sound_1 := preload("res://Rageborn/Attacks/Provoker/HitSounds/ProvokerHitSound1.tscn")
var hit_sound_2 := preload("res://Rageborn/Attacks/Provoker/HitSounds/ProvokerHitSound2.tscn")
var hit_sound_3 := preload("res://Rageborn/Attacks/Provoker/HitSounds/ProvokerHitSound3.tscn")
var hit_sounds := [hit_sound_1, hit_sound_2, hit_sound_3]



func init(rageborne):
	Main.add_child(self)
	var spawn_position = Vector2.RIGHT
	spawn_position *= 70 + 400 * randf()
	spawn_position = spawn_position.rotated(PI * randf())
	global_position = rageborne.global_position + spawn_position
	

func init_debug():
	debug = true
	Main.add_child(self)
	global_position = Main.viewport_size / 2
	global_position.x += (randf() * 2 - 1) * 200	
	global_position.y += (randf() * 2 - 1) * 200
	
	
func _ready():
	$Sprite.visible = false
	layers = 0b0
	if debug:
		spawn()
	else:
		$Particles2D.emitting = true
		get_tree().create_timer(2.4).connect("timeout", self, "spawn")
	Main.play_sound(summon_sound, position, 1)
	

func spawn():
	$Sprite.visible = true
	current_state = ProvokerState.MARCHING
	Main.add_hp_bar(self)
	layers = 0b10
	$SpawnSound.play()
	
	
func _process(delta: float):
	if current_state == ProvokerState.MARCHING:
		update_targets_in_range()
		do_movement(delta)
		do_attack(delta)
		

func update_targets_in_range():
	targets_in_range = []
	
	var gravehold_top = Main.gravehold.global_position.y - Main.gravehold.get_node("CollisionShape2D").shape.extents.y
	if global_position.y + RANGE >= gravehold_top:
		targets_in_range.append(Main.gravehold)
	
	for player in Main.players:
		if global_position.distance_to(player.global_position) < RANGE:
			targets_in_range.append(player)
	
	
func do_movement(delta: float):
	var factor = 1 if targets_in_range.size() == 0 else 0
	var speed = SPEED * delta * factor
	for buff in buffs:
		speed = buff.modify_speed(speed)
	position += Vector2.DOWN * speed
	
	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float) -> float:
	var hp_before := hp
	hp -= damage
	var overkill_damage := -hp
	hp = clamp(hp, 0, MAX_HP)
	
	Main.show_damage_number(hp - hp_before, global_position)
	var sounds: Array
	if hp <= 0:
		sounds = death_sounds
		queue_free()
	else :
		sounds = hit_sounds
	Main.play_sound(sounds[randi() % sounds.size()], position, 0, sound_pitch)
	
	return overkill_damage


func do_attack(delta: float):
	if time_since_last_attack <= ATTACK_COOLDOWN:
		time_since_last_attack += delta
		
	if time_since_last_attack >= ATTACK_COOLDOWN and targets_in_range.size() > 0 :
		throw_spear()
	
	
func throw_spear():
	time_since_last_attack -= ATTACK_COOLDOWN
	var spear = spear_scene.instance()
	spear.init(self)
	
	
func add_buff(buff):
	buffs.append(buff)
	
	
func remove_buff(buff):
	buffs.erase(buff)
