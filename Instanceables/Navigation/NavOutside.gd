extends Node3D

enum RoomType {BOX, CYLINDER, OUTSIDEBOX, OUTSIDECYLINDER}
@export var roomName : String
var roomNum : int
@export var area : int
@export var doors : Array[Vector3]
@export var enclosedRooms : Array[Node3D]
var navAroundPoints : Array[Vector3]
var navPointsConnections : Dictionary

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
	connectPoints()
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

func connectPoints():
	for point in navAroundPoints:
		for crossPoint in navAroundPoints:
			if lineCheckRooms(point,crossPoint):
				if navPointsConnections.has(point):
					navPointsConnections[point].append(crossPoint)
				else:
					navPointsConnections[point] = [crossPoint]

func lineCheckRooms(from:Vector3,to:Vector3):
	for room in enclosedRooms:
		if room.boundingCube.intersects_segment(from,to) != null:
			return false
	return true

func navigateOutside(from:Vector3, to:Vector3):
	if lineCheckRooms(from,to):
		return [(to - from).length(),to]
	#Create a set of all unvisited nodes: the unvisited set.
	var unvisited = navAroundPoints.duplicate()
	unvisited.append(to)
	unvisited.append(from)
	#Assign to every node a distance from start value: for the starting node, it is zero, and for 
		#all other nodes, it is infinity, since initially no path is known to these nodes. During 
		#execution, the distance of a node N is the length of the shortest path discovered so far 
		#between the starting node and N.
	var dist : Dictionary
	for point in unvisited:
		if from.distance_to(point) < 0.2:
			unvisited.erase(point)
			continue
		dist[point] = [from.distance_to(point),point]
	#From the unvisited set, select the current node to be the one with the smallest (finite) 
		#distance; initially, this is the starting node (distance zero). If the unvisited set is 
		#empty, or contains only nodes with infinite distance (which are unreachable), then the 
		#algorithm terminates by skipping to step 6. If the only concern is the path to a target 
		#node, the algorithm terminates once the current node is the target node. Otherwise, the 
		#algorithm continues.
	var cur = from
	while true:
		if unvisited.size() == 0 or cur == to:
			break
		cur = from
		var curdist = 1000000000
		for point in unvisited:
			if dist.has(point) and curdist > dist[point][0]:
				cur = point
				curdist = dist[point][0]
		#For the current node, consider all of its unvisited neighbors and update their distances 
			#through the current node; compare the newly calculated distance to the one currently 
			#assigned to the neighbor and assign the smaller one to it. For example, if the current node 
			#A is marked with a distance of 6, and the edge connecting it with its neighbor B has length 
			#2, then the distance to B through A is 6 + 2 = 8. If B was previously marked with a 
			#distance greater than 8, then update it to 8 (the path to B through A is shorter). 
			#Otherwise, keep its current distance (the path to B through A is not the shortest).
		var connections = navPointsConnections[cur].duplicate()
		if lineCheckRooms(cur,to):
			connections.append(to)
		for point in connections:
			var pdist = dist[cur][0] + (cur.distance_to(point))
			if dist.has(point):
				if dist[point][0] > pdist:
					dist[point] = [pdist,dist[cur]]
			else:
				dist[point] = [pdist,dist[cur]]
		#After considering all of the current node's unvisited neighbors, the current node is removed 
			#from the unvisited set. Thus a visited node is never rechecked, which is correct because the 
			#distance recorded on the current node is minimal (as ensured in step 3), and thus final. Repeat 
			#from step 3.
		unvisited.erase(cur)
	
	#Once the loop exits (steps 3–5), every visited node contains its shortest distance from the 
		#starting node.
	var shortest
	for d in dist:
		if d[0] < shortest[0]:
			shortest = d
	return shortest[1]

func isInRoom(point : Vector3):
	var inside = false
	match type:
		RoomType.OUTSIDEBOX:
			if rotation != Vector3.ZERO:
				var locpoint = to_local(point)
				locpoint = locpoint.rotated(Vector3.UP, -rotation.y)
				point = to_global(locpoint)
			inside = boundingCube.has_point(point)
		RoomType.OUTSIDECYLINDER:
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
