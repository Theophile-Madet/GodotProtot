extends Area2D


const MAX_CHARGE := 2
var current_charge : float

var input_action: String
var player: Node2D
var circle_base_scale: float

enum FeralLightningState {
	CHARGING,
	CASTED,
}
var current_state

var enemies_in_range: Array = []

func init(_player: Node2D):
	player = _player
	global_position = player.global_position
	input_action = "player_%s_rune_top" % player.player_index
	circle_base_scale = $Circle.scale.x
	$Circle.scale = Vector2.ZERO
	player.main.add_child(self)
	

func _ready():
	$ParticlesCircle.emitting = true
	current_charge = player.BACKSWING_DURATION
	current_state = FeralLightningState.CHARGING
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")
	var endColor = $Circle.modulate
	var startColor = endColor
	startColor.a = 0
	$Circle.modulate = startColor
	
	var tween := Tween.new()
	tween.interpolate_property($Circle, "modulate", startColor, endColor, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
	add_child(tween)
	tween.start()
	


func charge(delta: float):
	current_charge += delta
	var charge_ratio := current_charge / MAX_CHARGE
	$Circle.scale = Vector2.ONE * charge_ratio * circle_base_scale
	($CollisionShape2D.shape as CircleShape2D).radius = 184 * charge_ratio
	if current_charge >= MAX_CHARGE:
		cast()
	
	
func cast():
	player.start_backswing()
	current_state = FeralLightningState.CASTED
	monitoring = true
	var charge_ratio := current_charge / MAX_CHARGE
	var material: ParticlesMaterial = $ParticlesSparks.process_material
	material.emission_sphere_radius = 150 * charge_ratio
	material.scale = 0.2 * charge_ratio
	$ParticlesSparks.amount = 5 * charge_ratio
	$ParticlesSparks.emitting = true
	get_tree().create_timer(1).connect("timeout", self, "queue_free")
	for enemy in enemies_in_range:
		enemy.hit(1)


func on_body_entered(body: RigidBody2D):
	enemies_in_range.append(body)
	
	
func on_body_exited(body: RigidBody2D):
	enemies_in_range.remove(enemies_in_range.find(body))
