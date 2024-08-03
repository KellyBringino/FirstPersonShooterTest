extends Node2D

@onready var weaponsCard = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer
@onready var mapsCard = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/MapCardsContainer
@onready var priLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/PrimaryCard/VBoxContainer/PrimaryCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/PrimaryLabelContainer/PrimaryLabel
@onready var secLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/SecondaryCard/VBoxContainer/SecondaryCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/SecondaryLabelContainer/SecondaryLabel
@onready var heaLabel = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/HeavyCard/VBoxContainer/HeavyCardContainer/VBoxContainer/LowerCardContainer/HBoxContainer/HeavyLabelContainer/HeavyLabel
@onready var priIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/PrimaryCard/VBoxContainer/PrimaryCardContainer/VBoxContainer/PrimaryCard/GunIconContainer/PrimaryGunIcon
@onready var secIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/SecondaryCard/VBoxContainer/SecondaryCardContainer/VBoxContainer/SecondaryCard/GunIconContainer/SecondaryGunIcon
@onready var heaIcon = $CanvasLayer/MarginContainer/MarginContainer/VBoxContainer/SelectionsContainer/VBoxContainer/CardsContainer/WeaponCardsContainer/HeavyCard/VBoxContainer/HeavyCardContainer/VBoxContainer/HeavyCard/GunIconContainer/HeavyGunIcon

const priMax = 3
const secMax = 2
const heaMax = 2
const mapMax = 2
const priLabels = ["None", "Rifle", "Sniper"]
const secLabels = ["Pistol", "Revolver"]
const heaLabels = ["None", "Rocket Launcher"]
const mapLabels = ["test", "Rooms"]
var priIcons = [load("res://Sprites/null.svg"),load("res://Sprites/rifle_icon.png"),load("res://Sprites/sniper_icon.png")]
var secIcons = [load("res://Sprites/pistol_icon.png"),load("res://Sprites/revolver_icon.png")]
var heaIcons = [load("res://Sprites/null.svg"),load("res://Sprites/rocketlauncher_icon.png")]

var cardSelection = 0;
var pri = 1
var sec = 0
var hea = 1
var map = 0

func _on_back_button_pressed():
	Utils.switchToMainMenu()

func _on_start_button_pressed():
	Game.choose(pri,sec+1,hea)
	Utils.loadLevel(0)

func moveCard(amount):
	cardSelection = (cardSelection + amount) % 2
	match cardSelection:
		0:
			mapsCard.hide()
			weaponsCard.show()
		1:
			weaponsCard.hide()
			mapsCard.show()

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

func moveMap(amount):
	map = (map + amount) % mapMax

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
	pass # Replace with function body.
func _on_map_selection_right_button_pressed():
	pass # Replace with function body.
