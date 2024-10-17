extends Enemy_General

var meleeList : Array = []

func _ready():
	speed = 5.5
	attackDist = 1.5
	moveDist = 2.5
	super._ready()

func _physics_process(_delta):
	super._physics_process(_delta)
	$ViewControl/vision/WeaponController/Weapon.global_rotation = $ModelController/doll/HandAttachment.global_rotation

func attack():
	playAnim("Attack",true)
	if meleeList.size() > 0:
		player.hit(attackdamage,global_position)
	#$ViewControl/vision/WeaponController/Weapon/Knife

func _on_melee_body_entered(body):
	meleeList.append(body)
func _on_melee_body_exited(body):
	for i in meleeList.size():
		if body == meleeList[i]:
			meleeList.remove_at(i)
			break
