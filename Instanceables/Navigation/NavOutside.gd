extends Node3D

enum RoomType {BOX, CYLINDER}
@export var roomName : String
var roomNum : int
@export var area : int
@export var doors : Array[Vector3]
@export var enclosedRooms : Array[Node3D]
var navAroundPoints : Array[Vector3]

@export var type : RoomType
#if box
@export var boundingCube : AABB
#if cylinder
@export var radius : float
@export var height : float

func registerOutside(ref : int):
	roomNum = ref
	boundingCube.position.x -= boundingCube.size.x/2
	boundingCube.position.y -= boundingCube.size.y/2
	boundingCube.position.z -= boundingCube.size.z/2
	for room in enclosedRooms:
		for point in room.NavAroundPoints:
			navAroundPoints.append(point)
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

func navigateOutside(from:Vector3, to:Vector3):
	#Create a set of all unvisited nodes: the unvisited set.
	
	#Assign to every node a distance from start value: for the starting node, it is zero, and for all other nodes, it is infinity, since initially no path is known to these nodes. During execution, the distance of a node N is the length of the shortest path discovered so far between the starting node and N.[18]
	#From the unvisited set, select the current node to be the one with the smallest (finite) distance; initially, this is the starting node (distance zero). If the unvisited set is empty, or contains only nodes with infinite distance (which are unreachable), then the algorithm terminates by skipping to step 6. If the only concern is the path to a target node, the algorithm terminates once the current node is the target node. Otherwise, the algorithm continues.
	#For the current node, consider all of its unvisited neighbors and update their distances through the current node; compare the newly calculated distance to the one currently assigned to the neighbor and assign the smaller one to it. For example, if the current node A is marked with a distance of 6, and the edge connecting it with its neighbor B has length 2, then the distance to B through A is 6 + 2 = 8. If B was previously marked with a distance greater than 8, then update it to 8 (the path to B through A is shorter). Otherwise, keep its current distance (the path to B through A is not the shortest).
	#After considering all of the current node's unvisited neighbors, the current node is removed from the unvisited set. Thus a visited node is never rechecked, which is correct because the distance recorded on the current node is minimal (as ensured in step 3), and thus final. Repeat from step 3.
	#Once the loop exits (steps 3–5), every visited node contains its shortest distance from the starting node.
	pass

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
	if inside:
		for r in enclosedRooms:
			inside = inside and !r.isInRoom(point)
	return inside
