extends InteractableBase


# Called when the node enters the scene tree for the first time.
func _ready():
	type = 1
	phrase = "Hold E to refill Primary Ammo"

func accessToolTip():
	if player.holdingPrimary:
		if player.primary.getReserveDiff() > 0:
			var a = ceil(player.primary.getReserveDiff() * player.primary.ammoCost)
			tooltip(phrase," (" + str(a) + " needed)",player.parts>=a)
		else:
			endtooltip()
	else:
		endtooltip()

func activate():
	if player.holdingPrimary:
		if player.primary.getReserveDiff() > 0:
			var due = ceil(player.primary.getReserveDiff() * player.primary.ammoCost)
			if player.parts >= due:
				player.primary.fillReserve()
				player.pay(due)
				endtooltip()
			else:
				rejectHelper()
