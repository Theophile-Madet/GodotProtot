extends Node


func _ready():
	create_debug_inputs()
	

func _process(delta: float):
	if Input.is_action_just_pressed("debug_spawn_provoker"):
		Constants.make_provoker().init_debug()
	if Input.is_action_just_pressed("debug_spawn_scorn"):
		Constants.make_scorn().init_debug()
	if Input.is_action_just_pressed("debug_spawn_laser"):
		Constants.make_laser().init_debug()
	if Input.is_action_just_pressed("debug_spawn_bloodcry"):
		Constants.make_bloodcry().init(null)
		
		
func create_debug_inputs():
	Main.create_input_action_keyboard("debug_spawn_provoker", KEY_F1)
	Main.create_input_action_keyboard("debug_spawn_scorn", KEY_F2)
	Main.create_input_action_keyboard("debug_spawn_laser", KEY_F3)
	Main.create_input_action_keyboard("debug_spawn_bloodcry", KEY_F4)
