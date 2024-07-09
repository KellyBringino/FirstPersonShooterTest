class_name Breakable
extends RigidBody3D

var health : float

func hit(_pos,damage):
	health -= damage
	if health <= 0:
		brake()

func brake():
	print("ahh oh no im broken")
	queue_free()
