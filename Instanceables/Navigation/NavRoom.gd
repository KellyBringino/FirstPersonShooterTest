extends Node3D

@export var roomName : String
@export var area : int
@export var boundingCube : AABB
@export var doors : Array[Vector3]
func registerRoom():
	boundingCube.position.x -= boundingCube.size.x/2
	boundingCube.position.y -= boundingCube.size.y/2
	boundingCube.position.z -= boundingCube.size.z/2
	return getRoom()
func getRoom():
	return {roomName = roomName, area = area, bounds = boundingCube,doors = doors}

func isInRoom(point : Vector3):
	var inside = boundingCube.has_point(point)
	for door in doors:
		inside = inside or point.distance_to(door) < 0.1
	return inside
