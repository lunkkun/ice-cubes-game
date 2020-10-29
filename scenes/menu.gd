extends Control


signal continue_button_pressed
signal new_game_button_pressed
signal level_picked(level_id)

var save_file_exists = false setget set_save_file_exists
var nr_levels = 0
var best_per_level = []

onready var _level_list = $MarginContainer/VBoxContainer/CenterContainer/LevelList
onready var _button_list = $MarginContainer/VBoxContainer/CenterContainer/ButtonList
onready var _continue_button = _button_list.get_node("ContinueButton")
onready var _new_game_dialog = $NewGameDialog


func set_save_file_exists(value):
	save_file_exists = value
	
	_continue_button.disabled = !save_file_exists


func _on_ContinueButton_pressed():
	emit_signal("continue_button_pressed")


func _on_NewGameButton_pressed():
	if save_file_exists:
		_new_game_dialog.popup()
	else:
		emit_signal("new_game_button_pressed")


func _on_PickLevelButton_pressed():
	# TODO: separate menu
	emit_signal("level_picked", 0)


func _on_ExitButton_pressed():
	print("exit")
	get_tree().quit()


func _on_NewGameDialog_confirmed():
	emit_signal("new_game_button_pressed")
