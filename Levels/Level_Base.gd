class_name Level_Base
extends Node

@onready var spawns : Array = $Spawns.get_children()

func _on_spawn_timer_timeout():
	var mainCandi = null
	var candidates = []
	for s in spawns:
		if mainCandi == null:
			mainCandi = s
			pass
		else:
			if $Player.global_transform.origin.distance_to(s.global_transform.origin) < \
			$Player.global_transform.origin.distance_to(mainCandi.global_transform.origin):
				mainCandi = s
	print(mainCandi.name)
