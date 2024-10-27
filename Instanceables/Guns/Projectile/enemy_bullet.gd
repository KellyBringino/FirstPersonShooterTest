extends RigidBody3D

var damage

func setup(d):
	damage = d

func _on_area_3d_body_entered(body):
	while !body.editor_description.contains("Player") && body != get_node("/root/World"):
		body = body.get_parent()
	if body.editor_description.contains("Player"):
		body.hit(damage,global_position)
	queue_free()


func _on_death_timer_timeout():
	queue_free()
