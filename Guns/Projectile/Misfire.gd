extends Node3D

@onready var debris : GPUParticles3D = $Debris
@onready var smoke : GPUParticles3D = $Smoke

# Called when the node enters the scene tree for the first time.
func _ready():
	debris.emitting = true
	smoke.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
