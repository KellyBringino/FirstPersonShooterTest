extends InteractableBase
class_name BenchBase


func weaponStatHelper(w):
	var elem = 0
	if w.fireWeapon:
		elem = 1
	elif w.iceWeapon:
		elem = 2
	get_node("/root/World/GUI").statUpdate(
		w.damageLevel,w.magLevel,elem)
