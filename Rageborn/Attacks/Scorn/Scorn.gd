extends RigidBody2D

class_name Scorn

const SPEED = 0
const SIZE = 48


const MAX_HP:= 3
var hp: float = MAX_HP
var boulder_scene: PackedScene = preload("res://Rageborn/Attacks/Scorn/Boulder/ScornBoulder.tscn")
const ATTACK_COOLDOWN := 5
var time_since_last_attack: float = 0
var sound_pitch = 0.5 + randf()
var buffs := []
var debug := false

var summon_sound := preload("res://Rageborn/Attacks/SummonSound/SummonSound.tscn")
var throw_sound := preload("res://Rageborn/Attacks/Scorn/ScornThrowSound.tscn")

var death_sound_1 := preload("res://Rageborn/Attacks/Scorn/DeathSounds/ScornDeathSound1.tscn")
var death_sound_2 := preload("res://Rageborn/Attacks/Scorn/DeathSounds/ScornDeathSound2.tscn")
var death_sound_3 := preload("res://Rageborn/Attacks/Scorn/DeathSounds/ScornDeathSound3.tscn")
var death_sounds := [death_sound_1, death_sound_2, death_sound_3]

var hit_sound_1 := preload("res://Rageborn/Attacks/Scorn/HitSounds/ScornHitSound1.tscn")
var hit_sound_2 := preload("res://Rageborn/Attacks/Scorn/HitSounds/ScornHitSound2.tscn")
var hit_sound_3 := preload("res://Rageborn/Attacks/Scorn/HitSounds/ScornHitSound3.tscn")
var hit_sounds := [hit_sound_1, hit_sound_2, hit_sound_3]

func init(rageborne):
	Main.add_child(self)
	var spawn_position := Vector2()
	spawn_position.x = 400 + (Main.viewport_size.x - 800) * randf()
	spawn_position.y = 150 + (Main.viewport_size.y / 2.5) * randf()
	global_position = spawn_position
	$Sprite.visible = false


func init_debug():
	debug = true
	Main.add_child(self)
	global_position = Main.viewport_size / 2
	global_position.x += (randf() * 2 - 1) * 200	
	global_position.y += (randf() * 2 - 1) * 200


func _ready():
	layers = 0b0
	if debug:
		spawn()
	else:
		$Particles2D.emitting = true
		get_tree().create_timer(2.4).connect("timeout", self, "spawn")
	get_tree().create_timer(0.2 * randf()).connect("timeout", self, "play_summon_sound")


func play_summon_sound():
	Main.play_sound(summon_sound, position, 1)
	

func spawn():
	$Sprite.visible = true
	Main.add_hp_bar(self)
	layers = 0b10
	$SpawnSound.play()
	
	
func _process(delta: float):
	time_since_last_attack += delta
	if time_since_last_attack > ATTACK_COOLDOWN:
		attack()
	
	
func get_current_hp():
	return hp
	

func get_max_hp():
	return MAX_HP
	
	
func hit(damage: float):
	var hp_before = hp
	hp -= damage
	var overkill_damage = -hp
	Main.show_damage_number(hp - hp_before, global_position)
	var sounds: Array
	if hp <= 0:
		sounds = death_sounds
		queue_free()
	else :
		sounds = hit_sounds
	Main.play_sound(sounds[randi() % sounds.size()], position, 0, sound_pitch)
	hp = clamp(hp, 0, MAX_HP)
	return overkill_damage
		

func attack():
	time_since_last_attack -= ATTACK_COOLDOWN
	var boulder = boulder_scene.instance()
	boulder.init(self)
	Main.play_sound(throw_sound, position, 0, 0.75 + randf() * 0.5)
	

func add_buff(buff):
	buffs.append(buff)
	
	
func remove_buff(buff):
	buffs.erase(buff)
