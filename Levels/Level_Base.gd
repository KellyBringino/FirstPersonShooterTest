class_name Level_Base
extends Node

const spawnerinstance = preload("res://Enemies/spawner.tscn")
const spawnDis = 25.0

@onready var spawns : Array = $Spawns.get_children()
var rng = RandomNumberGenerator.new()
var enemyMax : int = 7;
var enemyCount : int = 0;
var enemiesAtOnce : int = 3
var spawnRound : int = 0

func _ready():
	make_spawner()

func spawner_at(point):
	var s = spawnerinstance.instantiate()
	s.position = point
	add_child(s)
	var dif = enemyMax - enemyCount
	if (dif) > enemiesAtOnce:
		s.startup(enemiesAtOnce)
		enemyCount += enemiesAtOnce
	else:
		s.startup(dif)
		enemyCount += dif
	spawnRound += 1

func make_spawner():
	var mainCandi = null
	var candidates :Array = []
	for s in spawns:
		if $Player.global_transform.origin.distance_to(s.global_transform.origin) <= spawnDis:
			candidates.append(s)
		
		if mainCandi == null:
			mainCandi = s
		elif $Player.global_transform.origin.distance_to(s.global_transform.origin) < \
			$Player.global_transform.origin.distance_to(mainCandi.global_transform.origin):
				mainCandi = s
	if len(candidates) == 0:
		spawner_at(mainCandi.position)
	else:
		spawner_at(candidates[rng.randi_range(0,len(candidates)-1)].position)

func enemydeath(type):
	match type:
		0:#regular
			enemyCount -= 1
			$Player.addParts(Game.enemyStats.partCount)

func _on_spawn_timer_timeout():
	if enemyCount < enemyMax:
		make_spawner()
