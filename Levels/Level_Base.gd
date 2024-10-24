class_name Level_Base
extends Node

const spawnerinstance = preload("res://Instanceables/Enemies/spawner.tscn")
const spawnDis = 25.0

@onready var spawns : Array = $Spawns.get_children()
var rng = RandomNumberGenerator.new()
var enemyMax : int = 15;
var enemyCount : int = 0;
var enemiesAtOnce : int = 5
var roundMax : int = 5
var curRound : int = 0
var spawnRound : int = 0

var NormMatPreload : Dictionary = {}
var ExplMatPreload : Dictionary = {}
var FireMatPreload : Dictionary = {}
var IceMatPreload : Dictionary = {}

func _ready():
	for i in enemyMax:
		NormMatPreload[Game.normalmat.duplicate(true)] = true
		ExplMatPreload[Game.explmat.duplicate(true)] = true
		FireMatPreload[Game.firemat.duplicate(true)] = true
		IceMatPreload[Game.icemat.duplicate(true)] = true
	#make_spawner()

func spawner_at(point):
	var s = spawnerinstance.instantiate()
	s.position = point
	add_child(s)
	var dif = enemyMax - enemyCount
	if (dif) > enemiesAtOnce:
		s.startup(enemiesAtOnce,spawnRound)
		enemyCount += enemiesAtOnce
		curRound += enemiesAtOnce
	else:
		s.startup(dif,spawnRound)
		enemyCount += dif
		curRound += dif
	if curRound >= roundMax:
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

func getMat(index):
	match index:
		0:
			for m in NormMatPreload:
				if NormMatPreload[m] == true:
					NormMatPreload[m] = false
					return m
		1:
			for m in ExplMatPreload:
				if ExplMatPreload[m] == true:
					ExplMatPreload[m] = false
					return m
		2:
			for m in FireMatPreload:
				if FireMatPreload[m] == true:
					FireMatPreload[m] = false
					return m
		3:
			for m in IceMatPreload:
				if IceMatPreload[m] == true:
					IceMatPreload[m] = false
					return m
func freeMat(m,index):
	match index:
		0:
			NormMatPreload[m] = true
		1:
			ExplMatPreload[m] = true
		2:
			FireMatPreload[m] = true
		3:
			IceMatPreload[m] = true

func enemydeath(type):
	match type:
		0:#regular
			enemyCount -= 1
			$Player.addParts(Game.enemyStats.partCount)
	Game.killEnemy(type)

func _on_spawn_timer_timeout():
	if enemyCount < enemyMax:
		make_spawner()
