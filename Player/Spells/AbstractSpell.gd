extends Area2D

class_name AbstractSpell

var input_action: String
var current_charge := 0.0
var player : Node2D
var current_state

enum SpellState {
	CHARGING,
	CASTED,
}


func init(_player: Node2D):
	player = _player
	Main.add_child(self)
	input_action = "player_%s_rune_%s" % [player.player_index, rune()]
	scale = Vector2(0 , 0)


func _ready():
	current_state = SpellState.CHARGING
	$SoundCharge.play()
	charge(player.precharge, true)
	
	
func charge(delta: float, is_precharge: bool):
	if is_precharge:
		current_charge = min(delta, max_charge() / 2)
	else:
		current_charge += delta * 2
	current_charge = min(current_charge, max_charge())
	
	charge_implementation()
	
	if current_charge >= max_charge():
		cast()
		
		
func cast():
	player.finish_casting()
	current_state = SpellState.CASTED
	Main.play_sound(sound_cast(), position, get_sound_volume())
	$SoundCharge.stop()
	cast_implementation()
	
	
func get_sound_volume() -> float:
	return -12 * (1 - (current_charge / max_charge()))
	
	
func charge_ratio() -> float:
	return current_charge / max_charge()


func sound_cast() -> PackedScene:
	assert(false, "sound_cast() must be defined in spell script")
	return null
func charge_implementation():
	assert(false, "charge_implementation() must be defined in spell script")
func max_charge() -> float:
	assert(false, "max_charge() must be defined in spell script")
	return 0.0
func rune() -> String:
	assert(false, "rune() must be defined in spell script")
	return ""
func cast_implementation():
	assert(false, "cast_implementation() must be defined in spell script")
