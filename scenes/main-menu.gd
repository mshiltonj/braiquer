extends Control

@onready var how_to_back_to_main_btn = $HowToContainer/VBoxContainer/MarginContainer/BackToMain
@onready var credits_back_to_main_btn = $CreditsContainer/VBoxContainer/BackToMain
@onready var main_credits_btn = $MainMenuContainer/VBoxContainer2/MarginContainer/VBoxContainer/CreditsButton
@onready var main_how_to_btn = $MainMenuContainer/VBoxContainer2/MarginContainer/VBoxContainer/HowToButton

func _ready():
	get_tree().paused = false
	var back_to_main = func():
		toggle_hud_section('MainMenuContainer')
	
	how_to_back_to_main_btn.connect("pressed", back_to_main)
	credits_back_to_main_btn.connect("pressed", back_to_main)
	
	main_credits_btn.connect("pressed", func():
		toggle_hud_section("CreditsContainer")
	)
		
	main_how_to_btn.connect("pressed", func():
		toggle_hud_section("HowToContainer")
	)

func _on_button_pressed():
	print("START BUTTON PRESSED")
	var board_scene = preload("res://scenes/board/board.tscn")
	get_tree().change_scene_to_packed(board_scene)


func _on_quit_button_pressed():
	print("QUIT PRESSED")
	get_tree().quit()


func toggle_hud_section(hud_section_name: String):
	for section in get_tree().get_nodes_in_group('hud_sections'):
		if section.name == hud_section_name:
			section.visible = true
		else:
			section.visible = false
