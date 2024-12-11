class_name NavRoomAgent
extends Node3D

@onready var NavMain = $"../../../NavMain"
@onready var POI = global_position
@onready var next = global_position

func setNextPath():
	var newnext = NavMain.dijkstra(global_position, POI)
	if newnext == null:
		next = global_position
	else:
		next = newnext
	return next

func getNextPath():
	return next

func setPOI(point):
	POI = point
func getPOI():
	return POI
