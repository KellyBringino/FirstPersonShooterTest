extends RigidBody3D

var objects : Array = []
var damage : float

func setup(d):
	damage = d

func _on_body_entered(body):
	for index in objects.size():
		objects[index].hit(position,damage)


func _on_explosion_area_body_entered(body):
	$RayCast3D.look_at(body.global_transform.origin, Vector3.UP)
	$RayCast3D.force_raycast_update()
	if $RayCast3D.get_collider() == body:
		objects.append(body)

func _on_explosion_area_body_exited(body):
	for index in objects.size():
		if objects[index] == body:
			objects.remove_at(index)
			break
