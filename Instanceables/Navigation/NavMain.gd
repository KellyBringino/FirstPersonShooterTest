extends Node3D

var rooms : Array[CollisionShape3D]
var connectedRooms = {}

func _ready():
	for room in get_children():
		if room == $CollisionShape3D:
			continue
		rooms.append(room.registerArea())
	connectRooms()

func connectRooms():
	var roomdoors = {}
	for room in rooms:
		for door in room.doors:
			if door not in roomdoors:
				roomdoors[door] = room
			else:
				var r = roomdoors[door]
				if connectedRooms[room] == null:
					connectedRooms[room] = {door = r}
				else:
					connectedRooms[room].append(r)
				roomdoors.erase(door)
