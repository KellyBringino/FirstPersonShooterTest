class_name Level_Base
extends Node

const spawnerinstance = preload("res://Enemies/spawner.tscn")
const spawnDis = 25.0

@onready var spawns : Array = $Spawns.get_children()
var rng = RandomNumberGenerator.new()

func _ready():
	make_spawner()

func spawner_at(point):
	var s = spawnerinstance.instantiate()
	s.position = point
	add_child(s)
	s.startup(3)

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

func _on_spawn_timer_timeout():
	make_spawner()
