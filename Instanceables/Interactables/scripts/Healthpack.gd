extends InteractableBase


# Called when the node enters the scene tree for the first time.
func _ready():
	phrase = "Hold E to refill Health"

func accessToolTip():
	var health = player.health
	var maxHealth = player.maxHealth
	if health < maxHealth:
		var h = ceil((maxHealth - health) * Game.playerStats.healthCost)
		tooltip(phrase," (" + str(h) + " needed)",player.parts>=h)
	else:
		endtooltip()

func activate():
	var health = player.health
	var maxHealth = player.maxHealth
	if health < maxHealth:
		var due = ceil((maxHealth - health) * Game.playerStats.healthCost)
		if player.parts >= due:
			player.heal()
			player.pay(due)
			workbenchSound.play()
			endtooltip()
		else:
			rejectHelper()
