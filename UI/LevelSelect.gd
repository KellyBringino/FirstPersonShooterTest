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

const mapMax = 2
const priMax = 3
const secMax = 2
const heaMax = 2
const mapLabels = ["test", "Rooms"]
const priLabels = ["None", "Rifle", "Sniper"]
const secLabels = ["Pistol", "Revolver"]
const heaLabels = ["None", "Rocket Launcher"]
var mapIcons = []
var priIcons = [load("res://Sprites/null.svg"),load("res://Sprites/rifle_icon.png"),load("res://Sprites/sniper_icon.png")]
var secIcons = [load("res://Sprites/pistol_icon.png"),load("res://Sprites/revolver_icon.png")]
var heaIcons = [load("res://Sprites/null.svg"),load("res://Sprites/rocketlauncher_icon.png")]

var cardSelection = 0;
var pri = 1
var sec = 0
var hea = 1
var map = 0

func _ready():
	moveCardTo(0)
	setMap()

func _on_back_button_pressed():
	Utils.switchToMainMenu()
func _on_start_button_pressed():
	Game.choose(pri,sec+1,hea)
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
	#mapIcon.texture = mapIcons[map]
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
