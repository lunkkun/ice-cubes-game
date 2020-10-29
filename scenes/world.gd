extends Node2D


signal level_loaded(level_id, previous_best)
signal end_reached

export(Array, PackedScene) var levels = []

var level_index = 0
var best_per_level = []

var _level: Level

onready var _main = get_parent() # this is shady
onready var _hud = _main.get_node("HUD") # this is even more shady


func load_level():
	if _level:
		_level.queue_free()
		yield(_level, "tree_exited")
		
	if level_index >= levels.size():
		print("no more levels")
		emit_signal("end_reached")
		return
	
	var packed = levels[level_index]
	_level = packed.instance()
	add_child(_level)
	
	_connect_level()
	
	emit_signal("level_loaded", level_index + 1, get_previous_best())
	print("level %d loaded" % (level_index + 1))


func load_next_level():
	level_index += 1
	load_level()


func get_previous_best():
	if level_index < best_per_level.size():
		return best_per_level[level_index]
	else:
		return 0


func set_previous_best(moves):
	if level_index < best_per_level.size():
		best_per_level[level_index] = moves
	else:
		best_per_level.append(moves)


func _connect_level():
	_level.connect("block_moved", _hud, "_on_Level_block_moved")
	_level.connect("completed", _hud, "_on_Level_completed")
	_level.connect("completed", _main, "_on_Level_completed")
	_hud.connect("undo_button_pressed", _level, "undo")
	_hud.connect("reset_button_pressed", _level, "reset")
