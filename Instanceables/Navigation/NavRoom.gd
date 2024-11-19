extends Node3D

@export var roomName : String
@export var boundingCube : AABB
@export var doors : Array[Vector3]
func registerRoom():
	return {roomName = roomName, bounds = boundingCube,doors = doors}
