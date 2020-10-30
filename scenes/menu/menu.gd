extends Control


signal continue_button_pressed
signal new_game_button_pressed
signal level_picked(level_id)

export(PackedScene) var level_button
export(PackedScene) var score_label
# Exporting so these can be tested within the scene
export var best_per_level = [] setget set_best_per_level
export var nr_levels = 0

var save_file_exists = false setget set_save_file_exists

onready var _level_list = $MarginContainer/VBoxContainer/CenterContainer/LevelList
onready var _level_button_list = _level_list.get_node("HBoxContainer/LevelButtonList")
onready var _score_label_list = _level_list.get_node("HBoxContainer/ScoreLabelList")
onready var _button_list = $MarginContainer/VBoxContainer/CenterContainer/ButtonList
onready var _continue_button = _button_list.get_node("ContinueButton")
onready var _new_game_dialog = $NewGameDialog


func set_save_file_exists(value):
	save_file_exists = value
	
	_continue_button.disabled = !save_file_exists


func set_best_per_level(scores):
	best_per_level = scores
	_update_level_list()


func _update_level_list():
	get_tree().call_group("menu_level_items", "free")
	
	var levels_played = best_per_level.size()
	for level_id in range(levels_played):
		_add_level_button(level_id, best_per_level[level_id])
	
	if nr_levels > levels_played:
		_add_level_button(levels_played, 0)


func _add_level_button(level_id, score):
	var button = level_button.instance()
	button.text += str(level_id + 1)
	_level_button_list.add_child(button)
	button.set_owner(_level_button_list)
	button.connect("pressed", self, "_on_LevelButton_pressed", [level_id])
	
	var label = score_label.instance()
	label.text += str(score) if score else "--"
	_score_label_list.add_child(label)
	label.set_owner(_score_label_list)


func _on_ContinueButton_pressed():
	emit_signal("continue_button_pressed")


func _on_NewGameButton_pressed():
	if save_file_exists:
		_new_game_dialog.popup()
	else:
		emit_signal("new_game_button_pressed")


func _on_PickLevelButton_pressed():
	_button_list.hide()
	_level_list.show()


func _on_ExitButton_pressed():
	print("exit")
	get_tree().quit()


func _on_NewGameDialog_confirmed():
	emit_signal("new_game_button_pressed")


func _on_LevelListBackButton_pressed():
	_level_list.hide()
	_button_list.show()


func _on_LevelButton_pressed(level_id):
	emit_signal("level_picked", level_id)
	_level_list.hide()
	_button_list.show()
