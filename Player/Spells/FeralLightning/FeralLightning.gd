extends AbstractSpell

var enemies_in_range: Array = []
	

func _ready():
	global_position = player.global_position
	$ParticlesCircle.emitting = true
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
	


func charge_implementation():
	scale = Vector2.ONE * charge_ratio()
	($CollisionShape2D.shape as CircleShape2D).radius = 184 * charge_ratio()
	
	
func cast_implementation():
	monitoring = true
	
	var material: ParticlesMaterial = $ParticlesSparks.process_material
	material.emission_sphere_radius = 150 * charge_ratio()
	material.scale = 0.2 * charge_ratio()
	$ParticlesSparks.amount = 5 * charge_ratio()
	$ParticlesSparks.emitting = true
	get_tree().create_timer(1).connect("timeout", self, "queue_free")
	for enemy in enemies_in_range:
		enemy.hit(1)


func on_body_entered(body: RigidBody2D):
	enemies_in_range.append(body)
	
	
func on_body_exited(body: RigidBody2D):
	enemies_in_range.erase(body)


func sound_cast() -> PackedScene:
	return preload("FeralLightningSoundCast.tscn")
func max_charge() -> float:
	return 2.0
func rune() -> String:
	return "top"
