class_name SpreadShotGun
extends Gun

#const hitmark = preload("res://Instanceables/Guns/Projectile/pointMark.tscn")
const bulletInst = preload("res://Instanceables/Guns/Projectile/bullet_particle.tscn")

@onready var barrelEnd : Node3D = $BarrelEnd
@onready var splinterRay : RayCast3D = $BarrelEnd/ShootRay/SplinterRay

var flinch : float = 1.0
var pellets : int = 8
var rings : int = 3
var rng = RandomNumberGenerator.new()

func startup(object):
	flinch = object.flinch/20.0
	pellets = object.pellets
	rings = object.rings
	super.startup(object)

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		for i in pellets:
			splinterRay.rotation = Vector3.ZERO
			var rotref = -(shootRay.get_global_transform().basis.z)
			splinterRay.rotation_degrees.x = (i / floor(pellets/4.0))*4
			var angle = (i % int(floor(float(pellets)/float(rings)))) * ((2*PI)/(floor(float(pellets)/float(rings))))
			splinterRay.global_rotate(
				rotref,
				(angle + (((rng.randf() - 0.5) * rings)) * PI / floor(float(pellets)/float(rings)))
			)
			splinterRay.force_raycast_update()
			var object = splinterRay.get_collider()
			if (object != null):
				var colPoint = splinterRay.get_collision_point()
				var bullet = bulletInst.instantiate()
				get_tree().root.add_child(bullet)
				bullet.global_transform.origin = splinterRay.global_transform.origin
				bullet.global_rotation = splinterRay.global_rotation
				var dist = splinterRay.global_transform.origin.distance_to\
					(colPoint)
				bullet.startup(dist)
				#print(object.collision_layer)
				strike(object)
			else:
				var bullet = bulletInst.instantiate()
				get_tree().root.add_child(bullet)
				bullet.global_position = barrelEnd.global_position
				bullet.global_rotation = barrelEnd.global_rotation
				bullet.startup(100)
		
		get_node("/root/World/Player").recoil(flinch)
		var t = get_tree().create_tween()
		var f = Vector3(\
			rng.randf_range(0.0,flinch)\
			,rng.randf_range(-flinch,flinch)\
			,0.0)
		t.tween_property(barrelEnd,"rotation",barrelEnd.rotation + f,0.2)
		t.tween_property(barrelEnd,"rotation",Vector3(0,0,0),0.5)
		
		chambered = false
		$ShotTimer.start()
	else:
		grace = true
		$GraceTimer.start()

func reload():
	if mag < MAG_MAX && !(limited && reserve==0):
		reloading = true
		anim.play("Reload_Start",-1,reloadMult,false)
		if scope:
			get_node("/root/World/Player").releaseADS()
		await anim.animation_finished
		for i in MAG_MAX - mag:
			anim.play("Reload",-1,reloadMult,false)
			await anim.animation_finished
			if limited:
				reserve -= 1
			mag += 1
		anim.play("Reload_End",-1,reloadMult,false)
		await anim.animation_finished
		reloading = false
		if grace:
			fire()
