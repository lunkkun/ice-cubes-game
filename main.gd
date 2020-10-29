extends Node


const SAVE_FILE_PATH = "user://icecubes.save"

onready var _world = $World
onready var encryption_key = OS.get_unique_id() + ProjectSettings.get_setting("application/config/name")


func _ready():
	_load_save_file()
	_world.load_level()


func _load_save_file():
	var save_file = File.new()
	
	if not save_file.file_exists(SAVE_FILE_PATH):
		return
	
	var err = save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.READ, encryption_key)
	if not err:
		var save_data = parse_json(save_file.get_line())
		save_file.close()
		
		_world.best_per_level = save_data.scores
		#_world.level_index = save_data.scores.size() # load first level without a score


func _save_game():
	var save_data = {
		scores = _world.best_per_level,
	}
	
	var save_file = File.new()
	save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.WRITE, encryption_key)
	save_file.store_line(to_json(save_data))
	save_file.close()


func _on_Level_completed(moves):
	var previous_best = _world.get_previous_best()
	if not previous_best or moves < previous_best:
		_world.set_previous_best(moves)
	
	_save_game()
