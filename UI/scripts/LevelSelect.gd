extends Node2D

@onready var cardsTitle = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsTitleContainer/HBoxContainer/CardsTitleContainer/CardsTitle
@onready var weaponsCard = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer
@onready var mapsCard = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/MapCardsContainer
@onready var mapLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/MapCardsContainer/VBoxContainer/MapCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/MapLabel/MapLabel
@onready var priLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/PrimaryCard/VBoxContainer/PrimaryCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/PrimaryLabelContainer/PrimaryLabel
@onready var secLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/SecondaryCard/VBoxContainer/SecondaryCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/SecondaryLabelContainer/SecondaryLabel
@onready var heaLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/HeavyCard/VBoxContainer/HeavyCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/HeavyLabelContainer/HeavyLabel
@onready var mapIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/MapCardsContainer/VBoxContainer/MapCardContainer/VBoxContainer/MapCard/MapIconContainer/MapIcon
@onready var priIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/PrimaryCard/VBoxContainer/PrimaryCardContainer/VBoxContainer/PrimaryCard/GunIconContainer/PrimaryGunIcon
@onready var secIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/SecondaryCard/VBoxContainer/SecondaryCardContainer/VBoxContainer/SecondaryCard/GunIconContainer/SecondaryGunIcon
@onready var heaIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/HeavyCard/VBoxContainer/HeavyCardContainer/VBoxContainer/HeavyCard/GunIconContainer/HeavyGunIcon

var mapMax = 2
var priMax = 4
var secMax = 3
var heaMax = 3
var mapLabels = ["test", "Rooms"]
var priLabels = ["None", "Rifle", "Sniper", "Shotgun"]
var secLabels = ["Pistol", "Revolver", "SMG"]
var heaLabels = ["None", "Rocket Launcher", "Grenade Launcher"]
var mapIcons = [
	load("res://Assets/Sprites/UI/null.svg"),
	load("res://Assets/Sprites/Gun Icons/rifle_icon.png")]
var priIcons = [
	load("res://Assets/Sprites/UI/null.svg"),
	load("res://Assets/Sprites/Gun Icons/rifle_icon.png"),
	load("res://Assets/Sprites/Gun Icons/sniper_icon.png"),
	load("res://Assets/Sprites/Gun Icons/shotgun_icon.png")]
var secIcons = [
	load("res://Assets/Sprites/Gun Icons/pistol_icon.png"),
	load("res://Assets/Sprites/Gun Icons/revolver_icon.png"),
	load("res://Assets/Sprites/Gun Icons/smg_icon.png")]
var heaIcons = [
	load("res://Assets/Sprites/UI/null.svg"),
	load("res://Assets/Sprites/Gun Icons/rocketlauncher_icon.png"),
	load("res://Assets/Sprites/Gun Icons/grenadelauncher_icon.png")]

var cardSelection = 0;
var pri = 1
var sec = 0
var hea = 1
var map = 0

func _ready():
	moveCardTo(0)
	setMap()
	Game.setupLevelSelectIcons(self)

func setup(object):
	mapMax = object.mapMax
	priMax = object.priMax
	secMax = object.secMax
	heaMax = object.heaMax
	mapLabels = object.mapLabels
	priLabels = object.priLabels
	secLabels = object.secLabels
	heaLabels = object.heaLabels
	mapIcons = object.mapIcons
	priIcons = object.priIcons
	secIcons = object.secIcons
	heaIcons = object.heaIcons

func _on_back_button_pressed():
	Utils.switchToMainMenu()
func _on_start_button_pressed():
	Game.choose(pri,sec,hea)
	Utils.loadLevel(map)

func moveCardTo(page):
	match page:
		0:#maps (start here)
			cardsTitle.text = "Maps"
			weaponsCard.hide()
			mapsCard.show()
		1:#weapons
			cardsTitle.text = "Weapons"
			mapsCard.hide()
			weaponsCard.show()
func moveCard(amount):
	cardSelection = (cardSelection + amount) % 2
	moveCardTo(cardSelection)

func movePri(amount):
	pri = (pri + amount) % priMax
	priLabel.text = priLabels[pri]
	priIcon.texture = priIcons[pri]
func moveSec(amount):
	sec = (sec + amount) % secMax
	secLabel.text = secLabels[sec]
	secIcon.texture = secIcons[sec]
func moveHea(amount):
	hea = (hea + amount) % heaMax
	heaLabel.text = heaLabels[hea]
	heaIcon.texture = heaIcons[hea]

func setMap():
	mapLabel.text = mapLabels[map]
	mapIcon.texture = mapIcons[map]
func moveMap(amount):
	map = (map + amount) % mapMax
	setMap()

func _on_cards_left_button_pressed():
	moveCard(-1)
func _on_cards_right_button_pressed():
	moveCard(1)

func _on_primary_left_button_pressed():
	movePri(-1)
func _on_primary_right_button_pressed():
	movePri(1)
func _on_secondary_left_button_pressed():
	moveSec(-1)
func _on_secondary_right_button_pressed():
	moveSec(1)
func _on_heavy_left_button_pressed():
	moveHea(-1)
func _on_heavy_right_button_pressed():
	moveHea(1)

func _on_map_selection_left_button_pressed():
	moveMap(-1)
func _on_map_selection_right_button_pressed():
	moveMap(1)
