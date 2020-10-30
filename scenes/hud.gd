extends Control


signal undo_button_pressed
signal reset_button_pressed
signal next_button_pressed
signal menu_button_pressed

var _moves = 0
var _previous_best = 0

onready var _level_label = $LevelLabel
onready var _moves_label = $MovesLabel
onready var _previous_best_label = $PreviousBestLabel
onready var _message = $Message
onready var _undo_button = $UndoButton
onready var _reset_button = $ResetButton
onready var _next_button = $NextButton


func _reset():
	_undo_button.disabled = true
	_reset_button.disabled = true
	
	_reset_button.text = "Reset"
	_message.text = ""
	
	_moves = 0
	_update_moves_label()


func set_level(level_id: int, previous_best: int = 0):
	_reset()
	
	_level_label.text = "Level: %d" % level_id
	
	_previous_best = previous_best
	_update_previous_best_label()
	
	if _previous_best:
		_previous_best_label.show()
		_next_button.show()
	else:
		_previous_best_label.hide()
		_next_button.hide()


func _update_moves_label():
	_moves_label.text = "Moves: %d" % _moves


func _update_previous_best_label():
	_previous_best_label.text = "Previous best: %d" % _previous_best


func _on_Level_block_moved():
	_moves += 1
	_update_moves_label()
	
	if _undo_button.is_disabled():
		_undo_button.disabled = false
	
	if _reset_button.is_disabled():
		_reset_button.disabled = false


func _on_Level_completed(__moves):
	_undo_button.disabled = true
	_reset_button.text = "Retry"
	_next_button.show()
	
	if _previous_best and _moves < _previous_best:
		_message.text = "New best score!"
		_previous_best = _moves
	else:
		_message.text = "Level completed!"
		if not _previous_best:
			_previous_best = _moves


func _on_UndoButton_pressed():
	_moves -= 1
	_update_moves_label()
	
	if not _moves:
		_undo_button.disabled = true
		_reset_button.disabled = true
	
	emit_signal("undo_button_pressed")


func _on_ResetButton_pressed():
	_reset()
	
	if _previous_best:
		_update_previous_best_label()
		_previous_best_label.show()
	
	emit_signal("reset_button_pressed")


func _on_NextButton_pressed():
	emit_signal("next_button_pressed")


func _on_MenuButton_pressed():
	emit_signal("menu_button_pressed")
