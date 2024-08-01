class_name Breakable
extends RigidBody3D

var health : float

func hit(_pos,damage,_source):
	health -= damage
	if health <= 0:
		destroy()

func destroy():
	queue_free()
