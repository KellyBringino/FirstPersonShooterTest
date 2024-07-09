extends RigidBody3D

const explosionInstance = preload("res://Guns/Projectile/Explosion.tscn")

var objects : Array = []
var damage : float
var isExploding : bool = false

func setup(d):
	damage = d

func _on_explosion_area_body_entered(body):
	$RayCast3D.look_at(body.global_transform.origin, Vector3.UP)
	$RayCast3D.force_raycast_update()
	if $RayCast3D.is_colliding():
				var collider = $RayCast3D.get_collider()
				if collider == body:
					objects.append(body)

func _on_explosion_area_body_exited(body):
	for index in objects.size():
		if objects[index] == body:
			objects.remove_at(index)
			break

func destructableCheck(object):
	if object == null:
		return false
	return object.editor_description.contains("Enemy") or \
	object.editor_description.contains("Dest")

func _on_detonator_shape_body_entered(_body):
	if !isExploding:
		isExploding = true
		process_mode = Node.PROCESS_MODE_DISABLED
		#$rocket.hide()
		print("explosion!")
		for index in objects.size():
			var cur = objects[index]
			while !destructableCheck(cur):
				if cur == null:
					break
				cur = cur.get_parent()
			if destructableCheck(cur):
				cur.hit(position,damage)
		var expl = explosionInstance.instantiate()
		get_tree().root.add_child(expl)
		expl.global_position = global_position
		print("dead rocket")
		queue_free()
