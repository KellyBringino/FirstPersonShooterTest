extends Node3D

var rooms : Array
var connectedRooms :Dictionary = {}
var exits : Dictionary = {}
var  curArea := [0]

func _ready():
	for room in get_children():
		var r = room.registerRoom(rooms.size())
		rooms.append(r)
	connectRooms()

func connectRooms():
	var roomdoors = {}
	var roomdoorsback = {}
	for i in 2:
		for roomnum in len(rooms):
			if !curArea.has(rooms[roomnum].area):
				continue
			for door in rooms[roomnum].doors:
				if door not in roomdoors and door not in roomdoorsback:
					roomdoors[door] = rooms[roomnum]
				elif door in roomdoors and rooms[roomnum] == roomdoors[door]:
					if !door in exits:
						exits[door] = roomdoors[door]
				elif door in roomdoors and rooms[roomnum] != roomdoors[door]:
					_connectadd(rooms[roomnum],door,roomdoors[door])
					roomdoors.erase(door)
					roomdoorsback[door] = rooms[roomnum]
				elif door in roomdoorsback and rooms[roomnum] != roomdoorsback[door]:
					_connectadd(rooms[roomnum],door,roomdoorsback[door])
					roomdoorsback.erase(door)

func _connectadd(room, door, r):
	if room != r:
		if !connectedRooms.has(room):
			connectedRooms[room] = {door : r}
		else:
			connectedRooms[room][door] = r

func unlockArea(area):
	if !curArea.has(area):
		curArea.append(area)
	connectRooms()

func generatePath(from:Vector3,to:Vector3):
	return _generatePathHelper(from,to,[])[1]
func _generatePathHelper(from:Vector3,to:Vector3,visited:Array):
	var source :Array = locate(from)
	var dest = locate(to)
	var areaLock = true
	var closest = []
	if source.size() == 0 and dest.size() == 0:
		pass
	elif source.size() == 0 and dest.size() > 0:
		pass
	elif source.size() > 0 and dest.size() == 0:
		pass
	elif source.size() > 0 and dest.size() > 0:
		for s in source:
			for d in dest:
				if s == d:
					return [(to - from).length(),to]
				if s.area != d.area:
					areaLock = false
		for s in source:
			if visited.has(s):
				continue
			visited.append(s)
			var doors = connectedRooms[s].keys()
			doors = distSort(doors,from)
			for door in connectedRooms[s]:
				if visited.has(connectedRooms[s][door]) or (areaLock and connectedRooms[s][door].area != s.area):
					continue
				var v = visited.duplicate(true)
				var forwardPath = _generatePathHelper(door,to,v)
				if len(forwardPath) > 0:
					var dist = forwardPath[0] + (door - from).length()
					if len(closest) == 0 or dist < closest[0]:
						closest = forwardPath
						forwardPath[0] = dist
						forwardPath.insert(1,door)
	return closest

#instructions for Dijkstra's algorithm taken from wikipedia page
#https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
#implementation written by Kelly Bringino
func dijkstra(start:Vector3,end:Vector3):
		var source : Array = locate(start)
		var dest : Array = locate(end)
		if len(dest) == 0 or len(source) == 0:
			return null
		var dist = []
		for i in len(source):
			dist.append({source[i] : [0.0,[start]]})
			#points to a list. the list has the distance to get there and the path of doorways 
			#traveled to get to this room, so dist[room][0] gets the distance to this room, and 
			#dist[room][1][0] gets the start position, dist[room][1][1] gets the first choice, 
			#and dist[room][1][-1] gets the door traveled through to get into this room
		for si in len(source):
			#if the two are in the same room then go straight there
			if dest.has(source[si]):
				return end
			#Create a set of all the unvisited nodes called the unvisited set.
			var unvisited := connectedRooms.keys()
			var visited := []
			#Assign to every node a distance from start value: for the starting node, it is zero, 
				#and for all other nodes, it is infinity, since initially no path is known to these 
				#nodes. During execution of the algorithm, the distance of a node N is the length 
				#of the shortest path discovered so far between the starting node and N.
			
			
			#From the unvisited set, select the current node to be the one with the smallest finite 
				#distance; initially, this will be the starting node, which has distance zero. If 
				#the unvisited set is empty, or contains only nodes with infinite distance (which 
				#are unreachable), then the algorithm terminates by going to step 6. If we are only 
				#concerned about the path to a target node, we may terminate here if the current 
				#node is the target node. Otherwise, we can continue to find the shortest paths to 
				#all reachable nodes.
			var cur = [source[si],dist[si][source[si]][0]]
			while true:
				if len(unvisited) == 0:
					break
				cur = [source[si],10000000]
				for room in unvisited:
					if dist[si].has(room) and cur[1] > dist[si][room][0]:
						cur = [room,dist[si][room][0]]
				#if dest.has(cur[0]):
					#break
				#For the current node, consider all of its unvisited neighbors and update their distances 
					#through the current node; compare the newly calculated distance to the one currently 
					#assigned to the neighbor and assign it the smaller one. For example, if the current 
					#node A is marked with a distance of 6, and the edge connecting it with its neighbor B 
					#has length 2, then the distance to B through A is 6 + 2 = 8. If B was previously marked 
					#with a distance greater than 8, then update it to 8 (the path to B through A is 
					#shorter). Otherwise, keep its current distance (the path to B through A is not the 
					#shortest).
				var doors = connectedRooms[cur[0]].keys()
				doors = distSort(doors,dist[si][cur[0]][1][-1])
				for door in doors:
					if visited.has(connectedRooms[cur[0]][door]):
						continue
					var doordist = dist[si][cur[0]][0] + (door - dist[si][cur[0]][1][-1]).length() + 0.2
					if not dist[si].has(connectedRooms[cur[0]][door]) or \
					dist[si][connectedRooms[cur[0]][door]][0] > doordist:
						var newpath = dist[si][cur[0]][1].duplicate(true)
						newpath.append(door)
						dist[si][connectedRooms[cur[0]][door]] = [doordist,newpath]
				#When we are done considering all of the unvisited neighbors of the current node, mark the 
					#current node as visited and remove it from the unvisited set. This is so that a visited 
					#node is never checked again, which is correct because the distance recorded on the 
					#current node is minimal (as ensured in step 3), and thus final. Go back to step 3.
				unvisited.erase(cur[0])
				visited.append(cur[0])
			#Once the loop exits (steps 3–5), every visited node will contain its shortest distance 
				#from the starting node.
		if len(dest) == 1 and len(source) == 1:
			if dist[0].has(dest[0]):
				return dist[0][dest[0]][1][1]
			return null
		var bestpath = dist[0][dest[0]][1]
		var shortpath = dist[0][dest[0]][0]
		for si in len(source):
			for d in dest:
				if dist[si][d][0] < shortpath:
					bestpath = dist[si][d][1]
					shortpath = dist[si][d][0]
		return bestpath[1]

func distSort(arr:Array,target:Vector3):
	for i in len(arr):
		var minindex = i
		for j in range(i+1,len(arr)):
			if arr[j].distance_to(target) < arr[minindex].distance_to(target):
				minindex = j
		var temp = arr[i]
		arr[i] = arr[minindex]
		arr[minindex] = temp
	return arr

func locate(point:Vector3,omit:Array = []):
	var rlst = []
	for room in get_children():
		if room.isInRoom(point) and not omit.has(room.getRoom()):
			rlst.append(room.getRoom())
	return rlst
