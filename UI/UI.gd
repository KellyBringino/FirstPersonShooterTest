extends Node2D

@onready var GUI = $CanvasLayer/InGameGUI
@onready var pauseMenu = $CanvasLayer/PauseMenu
@onready var hitmark = $CanvasLayer/HitmarkContainer/Hitmark
@onready var scope = $CanvasLayer/ScopeContainer
@onready var gameOverMenu = $CanvasLayer/GameOverMenu

@onready var healthbar = $CanvasLayer/InGameGUI/HealthBarContainer/HealthBarController/HealthBar
@onready var ammobar = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoBar
@onready var ammocounter = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoBar/VBoxContainer/AmmoCounter
@onready var partscounter = $CanvasLayer/InGameGUI/InfoBox/InfoContainer/PartsLabel
@onready var tooltipcontainer = $CanvasLayer/InGameGUI/ToolTipCenterContainer
@onready var selectionWheel = $CanvasLayer/InGameGUI/AmmoContainer/selection_wheel
@onready var iconWheel = $CanvasLayer/InGameGUI/AmmoContainer/selection_wheel

@onready var labelList = \
gameOverMenu.get_node("MenuItemsContainer/VBoxContainer/LabelsContainer/VBoxContainer")
@onready var scoreLabel = \
labelList.get_node("ScoreLabelContainer/ScoreLabel")
@onready var highScoreLabel = \
labelList.get_node("HighScoreLabelContainer/HighScoreLabel")
@onready var killsLabel = \
labelList.get_node("KillsLabelContainer/KillsLabel")

@onready var pausemain = $CanvasLayer/PauseMenu/MenuItemsContainer
@onready var options = $CanvasLayer/PauseMenu/OptionsItemsContainer
@onready var optionsList = \
options.get_node("VBoxContainer/OptionsListContainer/ScrollContainer/OptionsVBox")
@onready var hsensbar = \
optionsList.get_node("HSensContainer/HBoxContainer/HSliderContainer/HSensSlider")
@onready var vsensbar = \
optionsList.get_node("VSensContainer/HBoxContainer/VSliderContainer/VSensSlider")

var player
var weapons
var holdingPri : bool = true
var holdingHea : bool = false
var scoped : bool = false
var gameover : bool = false
var textFlash : bool = false
var flashCycles : int = 0
var hsens : float = 6.0
var vsens : float = 6.0

func setup():
	unpause()
	hideTooltip()
	gameOverMenu.hide()
	GUI.show()
	hitmark.show()
	player = $"../Player"
	healthbar.max_value = int(player.maxHealth)
	healthbar.set_value_no_signal(player.health)
	partscounter.text = "Parts: " + str(player.parts)

func _process(_delta):
	if !gameover:
		ammobar.max_value = player.heldGun.MAG_MAX
		ammobar.value = player.heldGun.mag
		ammocounter.text = str(player.heldGun.mag)
		match player.heldGun.gunType:
			0:#secondary
				ammocounter.set("theme_override_colors/font_color", Color.WHITE)
			1:#primary
				ammocounter.set("theme_override_colors/font_color", Color.GREEN)
			2:#heavy
				ammocounter.set("theme_override_colors/font_color", Color.PURPLE)
		if player.heldGun.limited:
			ammocounter.text += " / " + str(player.heldGun.reserve)
		partscounter.text = "Parts: " + str(player.parts)

func setHealth(n):
	healthbar.set_value_no_signal(n)

func scopein():
	if !Game.pauseCheck() and !gameover:
		scoped = true
		hideTooltip()
		GUI.hide()
		scope.show()
func unscope():
	if !Game.pauseCheck() and !gameover:
		scoped = false
		scope.hide()
		GUI.show()

func showTooltip(s,n,a):
	if !scoped and !gameover:
		tooltipcontainer.show()
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipLabel").text = s
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipNumberLabel").text = n
		if a:
			tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipNumberLabel").set("theme_override_colors/font_color", Color.WHITE)
		else:
			tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipNumberLabel").set("theme_override_colors/font_color", Color.RED)
func hideTooltip():
	if !scoped and !gameover:
		tooltipcontainer.hide()
func correctToolTip(a):
	if a:
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipNumberLabel").set("theme_override_colors/font_color", Color.WHITE)
	else:
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipNumberLabel").set("theme_override_colors/font_color", Color.RED)
func rejectToolTip():
	textFlash = true
	flashCycles = 5
	tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipLabel").set("theme_override_colors/font_color", Color.RED)
	$FlashTimer.start() 

func pause():
	if !gameover:
		pauseMenu.show()
		pauseSwitchTo(0)
func unpause():
	pauseMenu.hide()
func pauseSwitchTo(page):
	match page:
		0:
			options.hide()
			pausemain.show()
		1:
			pausemain.hide()
			options.show()
			hsensbar.value = int((Game.horizontalSensitivity - 0.2) * 10)
			vsensbar.value = int((Game.verticalSensitivity - 0.2) * 10)

func gameOver():
	gameover = true
	GUI.hide()
	hitmark.hide()
	unpause()
	gameOverMenu.show()
	scoreLabel.text = "Score: " + str(Game.getScore())
	highScoreLabel.text = "High Score: " + str(Game.getHighScore())
	killsLabel.text = "Kills: " + str(Game.getKills())

func pointgun(point):
	var cam = get_tree().root.get_camera_3d()
	if !cam.is_position_behind(point):
		var pos = cam.unproject_position(point)
		hitmark.position = pos
	else:
		hitmark.position = $CanvasLayer/InGameGUI/CrosshairCenterContainer.position
func dontpointgun():
	hitmark.position = $CanvasLayer/InGameGUI/CrosshairCenterContainer.position

func setWeapons(w):
	weapons = w
	var pri = 0
	var sec = 0
	var hea = 0
	if weapons[0] == Game.GunType.RIFLE:
		pri = 1
	elif weapons[0] == Game.GunType.SNIPER:
		pri = 2
	elif weapons[0] == Game.GunType.SHOTGUN:
		pri = 3
	if weapons[1] == Game.GunType.PISTOL:
		sec = 1
	elif weapons[1] == Game.GunType.REVOLVER:
		sec = 2
	if weapons[2] == Game.GunType.ROCKETLAUNCHER:
		hea = 1
	selectionWheel.setWeapons(pri,sec,hea)
	iconWheel.setStats(0,0,0)

func equip(hea,pri):
	holdingHea = hea
	holdingPri = pri
	selectionWheel.equip(hea,pri)
	iconWheel.setStats(0,0,0)

func _on_resume_button_pressed():
	Game.resume()
func _on_main_menu_button_pressed():
	Utils.returnToMainMenu()
func _on_level_select_button_pressed():
	Utils.levelSelect()
func _on_options_button_pressed():
	pauseSwitchTo(1)

func _on_try_again_button_pressed():
	unpause()
	Utils.retryLevel()

func _on_options_back_button_pressed():
	_on_options_save_button_pressed()
	pauseSwitchTo(0)
func _on_options_save_button_pressed():
	Game.setSensitivity(0.2 + (hsens/10),0.2 + (vsens/10))

func _on_h_sens_slider_drag_ended(_value_changed):
	hsens = hsensbar.value
func _on_v_sens_slider_drag_ended(_value_changed):
	vsens = vsensbar.value


func _on_flash_timer_timeout():
	if textFlash:
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipLabel").set("theme_override_colors/font_color", Color.WHITE)
	else:
		tooltipcontainer.get_node("ToolTipContainer/HBoxContainer/ToolTipLabel").set("theme_override_colors/font_color", Color.RED)
	textFlash = !textFlash
	flashCycles -= 1
	if flashCycles != 0:
		$FlashTimer.start()


