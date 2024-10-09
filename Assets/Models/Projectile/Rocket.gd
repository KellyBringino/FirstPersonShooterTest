extends RigidBody3D

const explosionInstance = preload("res://Instanceables/Guns/Projectile/Explosion.tscn")
const fireRing = preload("res://Instanceables/Guns/Projectile/FireAOE.tscn")

var objects : Array = []
var damage : float
var isExploding : bool = false
var fireWeapon : bool = false
var iceWeapon : bool = false

func setup(d,fire,ice):
	damage = d
	fireWeapon = fire
	iceWeapon = ice

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
		for cur in objects:
			strike(cur)
		var expl = explosionInstance.instantiate()
		get_tree().root.add_child(expl)
		expl.global_position = global_position
		queue_free()

func strike(object):
	while !destructableCheck(object):
		if object == null:
			break
		object = object.get_parent()
	if destructableCheck(object):
		object.hit(position,damage,1)
		
		if fireWeapon:
			object.burn(5)
		elif iceWeapon:
			pass
