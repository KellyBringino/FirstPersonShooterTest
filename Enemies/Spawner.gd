extends Node3D

const sinstance = preload("res://Enemies/Spawner.tscn")

var spawnAmount : int = 5
var countdown : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	countdown = spawnAmount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn():
	var s = sinstance.instantiate()
	$"../".add_child(s)
	print("spawning " + s.name)

func _on_timer_timeout():
	countdown -= 1
	print(countdown)
	$GPUParticles3D.emitting = true
	if countdown == 0:
		spawn()
	else:
		$Timer.start()
