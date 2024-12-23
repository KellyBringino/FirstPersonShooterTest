extends InteractableBase
class_name BenchBase

var locked:bool = false
var lockPhrase:String = "Unlock before use"

func weaponStatHelper(w):
	var elem = 0
	if w.fireWeapon:
		elem = 1
	elif w.iceWeapon:
		elem = 2
	get_node("/root/World/GUI").statUpdate(
		w.damageLevel,w.magLevel,elem)

func accessToolTip():
	if locked:
		tooltip(lockPhrase,"",false)
		return

func activate():
	if locked:
		rejectHelper()
		return

func lock():
	locked = true
func unlock():
	locked = false
func setLockPhrase(p:String):
	lockPhrase = p
