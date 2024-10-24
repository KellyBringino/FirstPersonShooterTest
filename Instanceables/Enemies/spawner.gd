extends Node3D

const CHANCE_OF_MELEE = 0.25

enum EnemyTypes {NORMAL, MELEE}

var amount : int = 5
var level : int
var countdown : int = 5
var firstEnemy : bool = true

func startup(a,l):
	amount = a
	level = l
	countdown = amount
	$splat.emitting = true
	$AudioStreamPlayer3D.play()
	$Timer.start()

func spawn():
	while amount > 0:
		var mob
		var stats
		if firstEnemy:
			var rng = randf()
			mob = Game.enemyBasicPreload if rng < 1.0 - CHANCE_OF_MELEE else Game.enemyMeleePreload
			stats = Game.enemyStats if rng < 1.0 - CHANCE_OF_MELEE else Game.enemyMeleeStats
			mob = mob.instantiate()
			firstEnemy = false
		else:
			mob = Game.enemyBasicPreload.instantiate()
			stats = Game.enemyStats
		mob.position = position + \
			Vector3(randf_range(-2,2),0,randf_range(-2,2))
		get_node("/root/World/Enemies").add_child(mob)
		mob.startup(
			stats.health + \
			(stats.levelHealth * level),
			stats.damage,
			level,
			stats
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
