extends Node3D

@export var roomName : String
@export var boundingCube : AABB
@export var doors : Array[Vector3]
func registerRoom():
	boundingCube.position.x -= boundingCube.size.x/2
	boundingCube.position.y -= boundingCube.size.y/2
	boundingCube.position.z -= boundingCube.size.z/2
	return getRoom()
func getRoom():
	return {roomName = roomName, bounds = boundingCube,doors = doors}

func isInRoom(point : Vector3):
	return boundingCube.has_point(point)
