extends Node2D

var Hsensitivity : float = 6
var Vsensitivity : float = 6

func _ready():
	$CanvasLayer/OptionsContainer/VBoxContainer/OptionsMenuContainer/VBoxContainer/ListContainer/ScrollContainer/OptionsVBox/HSensContainer/HBoxContainer/HSliderContainer/HSensSlider\
	.value = int((Game.horizontalSensitivity - 0.2) * 10)
	
	$CanvasLayer/OptionsContainer/VBoxContainer/OptionsMenuContainer/VBoxContainer/ListContainer/ScrollContainer/OptionsVBox/VSensContainer/HBoxContainer/VSliderContainer/VSensSlider\
	.value = int((Game.verticalSensitivity - 0.2) * 10)

func _on_back_button_pressed():
	Utils.switchToMainMenu()

func _on_save_button_pressed():
	Game.horizontalSensitivity = 0.2 + (Hsensitivity/10)
	Game.verticalSensitivity = 0.2 + (Vsensitivity/10)

func _on_h_sens_slider_drag_ended(value_changed):
	Hsensitivity = $CanvasLayer/OptionsContainer/VBoxContainer/OptionsMenuContainer/VBoxContainer/ListContainer/ScrollContainer/OptionsVBox/HSensContainer/HBoxContainer/HSliderContainer/HSensSlider.value


func _on_v_sens_slider_drag_ended(value_changed):
	Vsensitivity = $CanvasLayer/OptionsContainer/VBoxContainer/OptionsMenuContainer/VBoxContainer/ListContainer/ScrollContainer/OptionsVBox/VSensContainer/HBoxContainer/VSliderContainer/VSensSlider.value
