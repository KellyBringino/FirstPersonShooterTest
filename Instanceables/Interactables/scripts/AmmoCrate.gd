extends InteractableBase


# Called when the node enters the scene tree for the first time.
func _ready():
	phrase = "Hold E to refill Heavy Ammo"

func accessToolTip():
	if player.holdingHeavy:
		if player.heavy.getReserveDiff() > 0:
			var a = ceil(player.heavy.getReserveDiff() * player.heavy.ammoCost)
			tooltip(phrase," (" + str(a) + " needed)",player.parts>=a)
		else:
			endtooltip()
	else:
		endtooltip()

func activate():
	if player.holdingHeavy:
		if player.heavy.getReserveDiff() > 0:
			var due = ceil(player.heavy.getReserveDiff() * player.heavy.ammoCost)
			if player.parts >= due:
				acceptHelper()
				player.heavy.fillReserve()
				player.pay(due)
			else:
				rejectHelper()
