extends BenchBase


# Called when the node enters the scene tree for the first time.
func _ready():
	phrase = "Hold E to Burn Your "
	maxPhrase = "Weapon is Already Consumed"

func accessToolTip():
	var a
	if player.holdingHeavy:
		if (player.heavy.checkElement() != 0):
			tooltip(maxPhrase,"",false)
		else:
			a = ceil(player.heavy.elementalUpgradeCost)
			tooltip(phrase + "Heavy weapon"," (" + str(a) + " needed)",player.parts>=a)
	else:
		if player.holdingPrimary:
			if (player.primary.checkElement() != 0):
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.primary.elementalUpgradeCost)
				tooltip(phrase + "Primary weapon"," (" + str(a) + " needed)",player.parts>=a)
		else:
			if (player.secondary.checkElement() != 0):
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.secondary.elementalUpgradeCost)
				tooltip(phrase + "Secondary weapon"," (" + str(a) + " needed)",player.parts>=a)

func activate():
	var due = 0
	if player.holdingHeavy:
		due = ceil(player.heavy.elementalUpgradeCost)
		if player.parts >= due and player.heavy.checkElement() == 0:
			player.heavy.upgradeFire()
			player.pay(due)
			weaponStatHelper(player.heavy)
			workbenchSound.play()
		else:
			rejectHelper()
	else:
		if player.holdingPrimary:
			due = ceil(player.primary.elementalUpgradeCost)
			if player.parts >= due and player.primary.checkElement() == 0:
				player.primary.upgradeFire()
				player.pay(due)
				weaponStatHelper(player.primary)
				workbenchSound.play()
			else:
				rejectHelper()
		else: 
			due = ceil(player.secondary.elementalUpgradeCost)
			if player.parts >= due and player.secondary.checkElement() == 0:
				player.secondary.upgradeFire()
				player.pay(due)
				weaponStatHelper(player.secondary)
				workbenchSound.play()
			else:
				rejectHelper()
