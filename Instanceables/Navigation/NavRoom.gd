extends Node3D

@onready var boundingCube : CollisionShape3D = $CollisionShape3D
@export var doors : Array[Vector3] = []

func registerRoom():
	return {bounds = boundingCube,doors = doors}
