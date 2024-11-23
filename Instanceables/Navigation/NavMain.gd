extends Node3D

var rooms : Array
var connectedRooms = {}

func _ready():
	for room in get_children():
		var r = room.registerRoom()
		rooms.append(r)
	connectRooms()
	pass

func connectRooms():
	var roomdoors = {}
	var roomdoorsback = {}
	for i in 2:
		for roomnum in len(rooms):
			for door in rooms[roomnum].doors:
				if door not in roomdoors and door not in roomdoorsback:
					roomdoors[door] = rooms[roomnum]
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

func generatePath(from:Vector3,to:Vector3):
	return _generatePathHelper(from,to,[])[0]
func _generatePathHelper(from:Vector3,to:Vector3,visited:Array):
	var source :Array = locate(from)
	var dest = locate(to)
	var areaLock = true
	for s in source:
		for d in dest:
			if s == d:
				return [to,(to - from).length()]
			if s.area != d.area:
				areaLock = false
	var closest = null
	var closeDist := 100000
	for s in source:
		if visited.has(s):
			continue
		for door in connectedRooms[s]:
			if visited.has(connectedRooms[s][door]) or (areaLock and connectedRooms[s][door].area != s.area):
				continue
			print(connectedRooms[s][door].roomName)
			var v = visited.duplicate(true)
			v.append(s)
			var forwardPath = _generatePathHelper(door,to,v)
			if forwardPath[0] != null:
				var dist = forwardPath[1] + (door - from).length()
				if dist < closeDist:
					closest = door
					closeDist = (door-from).length()
			visited.append(connectedRooms[s][door])
	pass
	return [closest,closeDist]

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
