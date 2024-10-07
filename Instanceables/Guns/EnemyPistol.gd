extends Node3D

const pitchModMax = 0.5

@onready var BarrelEnd :Node3D = $BarrelEnd

const bullet_inst = preload("res://Instanceables/Guns/Projectile/enemy_bullet.tscn")

var damage
var velocity

func setup(d,v):
	damage = d
	velocity = v

func shoot():
	var modulation = (randf() * pitchModMax) - (pitchModMax/2.0)
	$AudioStreamPlayer3D.set_pitch_scale(1.0 + modulation)
	$AudioStreamPlayer3D.play()
	var bullet : RigidBody3D = bullet_inst.instantiate()
	get_node("/root/World").add_child(bullet)
	bullet.global_transform.origin = BarrelEnd.global_transform.origin
	bullet.global_rotation = BarrelEnd.global_rotation
	bullet.apply_central_force(-BarrelEnd.global_transform.basis.z * velocity)
	bullet.setup(damage)
