extends Node3D

const mark = preload("res://Instanceables/Guns/Projectile/pointMark.tscn")

enum RoomType {BOX, CYLINDER, OUTSIDEBOX, OUTSIDECYLINDER}
@export var roomName : String
var roomNum : int
@export var area : int
@export var doors : Array[Vector3]
@export var NavAroundPoints : Array[Vector3]

@export var type : RoomType
#if box
@export var boundingCube : AABB
#if cylinder
@export var radius : float
@export var height : float
func registerRoom(ref : int):
	roomNum = ref
	boundingCube.position.x -= boundingCube.size.x/2
	boundingCube.position.y -= boundingCube.size.y/2
	boundingCube.position.z -= boundingCube.size.z/2
	return getRoom()
func getRoom():
	return {roomName = roomName, 
		roomNum = roomNum,
		area = area, 
		type = type, 
		bounds = boundingCube, 
		radius = radius, 
		height = height,
		doors = doors, 
	}
	


func isInRoom(point : Vector3):
	var inside = false
	match type:
		RoomType.BOX:
			if rotation != Vector3.ZERO:
				var locpoint = to_local(point)
				locpoint = locpoint.rotated(Vector3.UP, -rotation.y)
				point = to_global(locpoint)
			inside = boundingCube.has_point(point)
		RoomType.CYLINDER:
			inside = radius > \
				Vector2(boundingCube.position.x,boundingCube.position.z).\
				distance_to(Vector2(point.x,point.z))
			inside = inside and point.y > boundingCube.position.y
			inside = inside and point.y < boundingCube.position.y + height
	for door in doors:
		inside = inside or point.distance_to(door) < 0.1
	return inside
