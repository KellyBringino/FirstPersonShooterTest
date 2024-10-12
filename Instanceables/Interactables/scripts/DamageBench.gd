extends BenchBase


func _ready():
	phrase = "Hold E to Upgrade Damage on "
	maxPhrase = "Weapon is Max Level"

func accessToolTip():
	var a
	if player.holdingHeavy:
		if !player.heavy.checkDamageLevel():
			tooltip(maxPhrase,"",false)
		else:
			a = ceil(player.heavy.damageUpgradeCost)
			tooltip(phrase + "Heavy weapon"," (" + str(a) + " needed)",player.parts>=a)
	else:
		if player.holdingPrimary:
			if !player.primary.checkDamageLevel():
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.primary.damageUpgradeCost)
				tooltip(phrase + "Primary weapon"," (" + str(a) + " needed)",player.parts>=a)
		else:
			if !player.secondary.checkDamageLevel():
				tooltip(maxPhrase,"",false)
			else:
				a = ceil(player.secondary.damageUpgradeCost)
				tooltip(phrase + "Secondary weapon"," (" + str(a) + " needed)",player.parts>=a)

func activate():
	var heavy = player.heavy
	var primary = player.primary
	var secondary = player.secondary
	var due = 0
	if player.holdingHeavy:
		due = ceil(heavy.damageUpgradeCost)
		if player.parts >= due and heavy.checkDamageLevel():
			heavy.upgradeDamage()
			player.pay(due)
			weaponStatHelper(heavy)
			workbenchSound.play()
		else:
			rejectHelper()
	else:
		if player.holdingPrimary:
			due = ceil(primary.damageUpgradeCost)
			if player.parts >= due and primary.checkDamageLevel():
				primary.upgradeDamage()
				player.pay(due)
				weaponStatHelper(primary)
				workbenchSound.play()
			else:
				rejectHelper()
		else: 
			due = ceil(secondary.damageUpgradeCost)
			if player.parts >= due and secondary.checkDamageLevel():
				secondary.upgradeDamage()
				player.pay(due)
				weaponStatHelper(secondary)
				workbenchSound.play()
			else:
				rejectHelper()
