extends Node


const SAVE_FILE_PATH = "user://savedata.save"

export(Array, PackedScene) var levels = []

var _save_file_exists = false
var _level_id = 0
var _best_per_level = []
var _level: Level

onready var _encryption_key = OS.get_unique_id() + ProjectSettings.get_setting("application/config/name")
onready var _world = $World
onready var _hud = $HUD
onready var _menu = $Menu


func _ready():
	_menu.nr_levels = levels.size()
	_menu.best_per_level = _best_per_level
	_load_save_file()


func load_next_level():
	_level_id += 1
	_load_level()


func get_previous_best():
	if _level_id < _best_per_level.size():
		return _best_per_level[_level_id]
	else:
		return 0


func set_previous_best(moves):
	if _level_id >= _best_per_level.size():
		_best_per_level.resize(_level_id + 1)
	
	_best_per_level[_level_id] = moves


func _load_level_from_menu(level_id):
	_level_id = level_id
	_load_level()
	
	_menu.hide()


func _load_level():
	if _level:
		_level.queue_free()
		if _level.get_parent():
			yield(_level, "tree_exited")
		
	if _level_id >= levels.size():
		print("no more levels")
		_hud.show_end()
		return
	
	var packed = levels[_level_id]
	_level = packed.instance()
	_world.add_child(_level)
	_level.set_owner(_world)
	
	_connect_level()
	
	_hud.set_level(_level_id + 1, get_previous_best())
	
	print("level %d loaded" % (_level_id + 1))


func _connect_level():
	_level.connect("block_moved", _hud, "_on_Level_block_moved")
	_level.connect("completed", _hud, "_on_Level_completed")
	_level.connect("completed", self, "_on_Level_completed")
	_hud.connect("undo_button_pressed", _level, "undo")
	_hud.connect("reset_button_pressed", _level, "reset")


func _load_save_file():
	var save_file = File.new()
	
	if not save_file.file_exists(SAVE_FILE_PATH):
		return
	
	var err = save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.READ, _encryption_key)
	if not err:
		_save_file_exists = true
		_menu.save_file_exists = true
		
		var save_data = parse_json(save_file.get_line())
		
		for score in save_data.scores:
			_best_per_level.append(score)
		
		print("save file loaded")
		
	save_file.close()


func _save_game():
	var save_data = {
		scores = _best_per_level,
	}
	
	var save_file = File.new()
	save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.WRITE, _encryption_key)
	save_file.store_line(to_json(save_data))
	save_file.close()
	
	_save_file_exists = true
	_menu.save_file_exists = true
	
	print("game saved")


func _on_Level_completed(moves):
	var previous_best = get_previous_best()
	if not previous_best or moves < previous_best:
		set_previous_best(moves)
	
	call_deferred("_save_game")


func _on_HUD_menu_button_pressed():
	print("show menu")
	_menu.show()
	
	if _level and _level.get_parent():
		_world.remove_child(_level)


func _on_Menu_continue_button_pressed():
	print("continue")
	if _level:
		_world.add_child(_level)
		_level.set_owner(_world)
	else:
		_level_id = _best_per_level.size() # load first level without a score
		_load_level()
	
	_menu.hide()


func _on_Menu_new_game_button_pressed():
	print("new game")
	_best_per_level.clear()
	call_deferred("_save_game")
	
	_load_level_from_menu(0)


func _on_Menu_level_picked(level_id):
	if not _save_file_exists:
		call_deferred("_save_game")
	
	_load_level_from_menu(level_id)
