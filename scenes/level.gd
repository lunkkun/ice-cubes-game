tool
class_name Level
extends Node2D


signal block_moved
signal completed(moves)

var _moves = []
onready var _target = $Target
onready var _blocks = get_tree().get_nodes_in_group("blocks")


func _ready():
	for block in _blocks:
		block.connect("move_started", self, "_on_Block_move_started")
		block.connect("move_stopped", self, "_on_Block_move_stopped")
		block.connect("moved_offscreen", self, "_on_Block_moved_offscreen")


func _get_configuration_warning():
	if not $Target:
		return "A level should always have one Target node"
	else:
		return ""


func undo():
	for block in _blocks:
		block.set_selected(false)
	
	if not _moves.empty():
		var move = _moves.pop_back()
		var block = move[0]
		var position = move[1]
		
		if not block.is_inside_tree():
			add_child(block)
		
		block.stop_moving()
		block.set_position(position)
		block.set_selected(true)


func reset():
	print("reset")
	for block in _blocks:
		if not block.is_inside_tree():
			add_child(block)
		
		block.reset()


func _set_blocks_pickable(value = true):
	get_tree().set_group("blocks", "input_pickable", value)


func _on_Block_move_started(block):
	_set_blocks_pickable(false)
	_moves.append([block, block.position])
	emit_signal("block_moved")


func _on_Block_move_stopped(block):
	yield(get_tree(), "physics_frame") # wait a frame to update collision
	
	if _target.overlaps_body(block):
		print("win!")
		emit_signal("completed", _moves.size())
	else:
		block.set_selected()
		_set_blocks_pickable()


func _on_Block_moved_offscreen(block):
	remove_child(block)
	_set_blocks_pickable()
