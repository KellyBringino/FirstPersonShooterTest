extends Node3D

var rooms : Array
var connectedRooms = {}

func _ready():
	for room in get_children():
		var r = room.registerRoom()
		rooms.append(r)
	connectRooms()
	pass

func _process(_delta):
	print(locate(get_node("/root/World/Player").global_position).roomName)

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
	_generatePathHelper(from,to,[])
func _generatePathHelper(from:Vector3,to:Vector3,visited:Array):
	var source = locate(from,visited)
	var dest = locate(to)
	if source == dest:
		return from - to
	var closest := (from - to) * INF
	for door in connectedRooms[source]:
		var v = visited
		v.append(source)
		var stuff = _generatePathHelper(door,to,v)
		var dist = stuff.length() + (from - door).length()
		if dist < closest.length():
			closest = (from - door).normalized() * dist
	return closest

func locate(point:Vector3,omit:Array = []):
	for room in get_children():
		if room.isInRoom(point) and not room in omit:
			return room.getRoom()
