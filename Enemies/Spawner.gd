extends Node3D

@export var mob_scene: PackedScene

var amount : int = 5
var countdown : int = 5

func startup(a):
	amount = a
	countdown = amount

func spawn():
	while amount > 0:
		var mob = mob_scene.instantiate()
		mob.position = position
		$"../".add_child(mob)
		amount -= 1
		await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_timer_timeout():
	countdown -= 1
	print(countdown)
	if countdown == 0:
		spawn()
	else:
		$GPUParticles3D.emitting = true
		$Timer.start()
