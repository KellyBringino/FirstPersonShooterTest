extends Node3D

@onready var NavMain = $"../../../NavMain"

func getNextPath(point):
	var POI = NavMain.dijkstra(global_position, point)
	if POI == null:
		return global_position
	return POI
