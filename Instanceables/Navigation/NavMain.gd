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
					connectadd(rooms[roomnum],door,roomdoors[door])
					roomdoors.erase(door)
					roomdoorsback[door] = rooms[roomnum]
				elif door in roomdoorsback and rooms[roomnum] != roomdoorsback[door]:
					connectadd(rooms[roomnum],door,roomdoorsback[door])
					roomdoorsback.erase(door)

func connectadd(room, door, r):
	if room != r:
		if !connectedRooms.has(room):
			connectedRooms[room] = {door : r}
		else:
			connectedRooms[room][door] = r
