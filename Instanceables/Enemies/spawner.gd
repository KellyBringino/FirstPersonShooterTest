extends Node3D

@export var mob_scene: PackedScene

var rng = RandomNumberGenerator.new()
var amount : int = 5
var level : int
var countdown : int = 5

func startup(a,l):
	amount = a
	level = l
	countdown = amount
	$splat.emitting = true
	$AudioStreamPlayer3D.play()
	$Timer.start()

func spawn():
	while amount > 0:
		var mob = mob_scene.instantiate()
		mob.position = position + \
			Vector3(rng.randf_range(-2,2),0,rng.randf_range(-2,2))
		get_node("/root/World/Enemies").add_child(mob)
		mob.startup\
		(\
			Game.enemyStats.health + \
			(Game.enemyStats.levelHealth * level),\
			Game.enemyStats.damage,\
			level\
		)
		amount -= 1
		await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_timer_timeout():
	countdown -= 1
	if countdown == 0:
		spawn()
	else:
		$splat.emitting = true
		$AudioStreamPlayer3D.play()
		$Timer.start()
