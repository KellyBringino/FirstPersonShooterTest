extends Node3D

@onready var NavMain = $"../../../NavMain"

func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	var point = NavMain.generatePath(get_parent().global_position, get_node("/root/World/Player").global_position)
	var loc = get_parent().global_position
	get_parent().get_node("line").look_at(point)
	get_parent().global_position += (point - get_parent().global_position).normalized() * .15
	pass
