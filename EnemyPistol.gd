extends Node3D

@onready var BarrelEnd :Node3D = $BarrelEnd

const bullet_inst = preload("res://Guns/Projectile/enemy_bullet.tscn")

var damage
var velocity

func setup(d,v):
	damage = d
	velocity = v

func shoot():
	var bullet : RigidBody3D = bullet_inst.instantiate()
	get_node("/root/World").add_child(bullet)
	bullet.global_transform.origin = BarrelEnd.global_transform.origin
	bullet.global_rotation = BarrelEnd.global_rotation
	bullet.apply_central_force(-BarrelEnd.global_transform.basis.z * velocity)
	bullet.setup(damage)
