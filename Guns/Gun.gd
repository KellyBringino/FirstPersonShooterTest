class_name Gun
extends Node3D

@onready var shootRay: RayCast3D = get_node("BarrelEnd/ShootRay")

var damage : float
var chambered : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire():
	if chambered:
		var object = shootRay.get_collider()
		if (object != null):
			#print("hit a " + str(object))
			if object.editor_description.contains("Enemy"):
				object.hit(shootRay.get_collision_point(),damage)
		$ShotTimer.start()

func singleFire():
	fire()
func heldFire():
	fire()

func _on_shot_timer_timeout():
	chambered = true
