extends BenchBase


# Called when the node enters the scene tree for the first time.
func _ready():
	phrase = "Hold E to Upgrade Magazine on "
	maxPhrase = "Weapon is Max Level"

func accessToolTip():
	super.accessToolTip()
	if locked:
		return
	var a
	if player.holdingHeavy:
		if !player.heavy.checkMagLevel():
			tooltip(maxPhrase,"",false)
		else:
			a = ceil(player.heavy.magUpgradeCost)
			tooltip(phrase + "Heavy weapon"," (" + str(a) + " needed)",player.parts>=a)
	else:
		if player.holdingPrimary:
			if !player.primary.checkMagLevel():
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.primary.magUpgradeCost)
				tooltip(phrase + "Primary weapon"," (" + str(a) + " needed)",player.parts>=a)
		else:
			if !player.secondary.checkMagLevel():
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.secondary.magUpgradeCost)
				tooltip(phrase + "Secondary weapon"," (" + str(a) + " needed)",player.parts>=a)

func activate():
	super.activate()
	if locked:
		return
	var due = 0
	if player.holdingHeavy:
		due = ceil(player.heavy.magUpgradeCost)
		if player.parts >= due and player.heavy.checkMagLevel():
			player.heavy.upgradeMag()
			player.pay(due)
			weaponStatHelper(player.heavy)
			workbenchSound.play()
		else:
			rejectHelper()
	else:
		if player.holdingPrimary:
			due = ceil(player.primary.magUpgradeCost)
			if player.parts >= due and player.primary.checkMagLevel():
				player.primary.upgradeMag()
				player.pay(due)
				weaponStatHelper(player.primary)
				workbenchSound.play()
			else:
				rejectHelper()
		else: 
			due = ceil(player.secondary.magUpgradeCost)
			if player.parts >= due and player.secondary.checkMagLevel():
				player.secondary.upgradeMag()
				player.pay(due)
				weaponStatHelper(player.secondary)
				workbenchSound.play()
			else:
				rejectHelper()
