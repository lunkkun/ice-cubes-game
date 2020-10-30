extends KinematicBody2D


signal move_started(block)
signal move_stopped(block)
signal moved_offscreen(block)

const DIRECTION = {
	LEFT = Vector2(-1, 0),
	UP = Vector2(0, -1),
	RIGHT = Vector2(1, 0),
	DOWN = Vector2(0, 1),
}

export var max_speed = 800.0
export var seconds_to_max_speed = 0.5

var selected = false setget set_selected

var _speed = 0.0
var _velocity: Vector2

onready var _visibility = $VisibilityNotifier2D
onready var _shape = $CollisionShape2D
onready var _direction_buttons = {
	LEFT = $ButtonLeft,
	UP = $ButtonUp,
	RIGHT = $ButtonRight,
	DOWN = $ButtonDown,
}
onready var _box = Rect2(-_shape.shape.extents, _shape.shape.extents * 2)
onready var _starting_position = position


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		set_selected(!selected)
		if selected:
			print("selected")


func _unhandled_input(event):
	if !selected:
		return
	
	if event.is_action_pressed("move_left"):
		print("move left")
		_start_moving(DIRECTION.LEFT)
	elif event.is_action_pressed("move_up"):
		print("move up")
		_start_moving(DIRECTION.UP)
	elif event.is_action_pressed("move_right"):
		print("move right")
		_start_moving(DIRECTION.RIGHT)
	elif event.is_action_pressed("move_down"):
		print("move down")
		_start_moving(DIRECTION.DOWN)
	
	elif (event is InputEventMouseButton) and event.pressed:
		var eventLocal = make_input_local(event)
		if !_box.has_point(eventLocal.position):
			print("clicked outside")
			set_selected(false)


func _physics_process(delta):
	if _velocity.length() != 0:
		if _speed < max_speed:
			_speed += delta / seconds_to_max_speed * max_speed
		
		var collision = move_and_collide(_velocity * _speed * delta)
		_handle_collision(collision)


func set_selected(value = true):
	selected = value
	
	for dir in DIRECTION:
		var button = _direction_buttons[dir]
		if selected and _can_move(DIRECTION[dir]):
			button.show()
		else:
			button.hide()


func stop_moving():
	_speed = 0
	_velocity *= 0


func reset():
	set_selected(false)
	_speed = 0
	_velocity *= 0
	set_position(_starting_position)
	input_pickable = true


func _can_move(velocity: Vector2):
	var collision = move_and_collide(velocity * 10000, true, true, true)
	
	if collision and collision.travel.length() < 1:
		return false
	else:
		return true


func _start_moving(velocity):
	if _can_move(velocity):
		_velocity = velocity
		set_selected(false)
		emit_signal("move_started", self)
	else:
		print("cannot travel")


func _handle_collision(collision):
	if collision:
		print("collision")
		stop_moving()
		set_position(position.round())
		emit_signal("move_stopped", self)
	elif not _visibility.is_on_screen():
		print("offscreen")
		stop_moving()
		emit_signal("moved_offscreen", self)


func _on_ButtonLeft_pressed():
	print("move left")
	_start_moving(DIRECTION.LEFT)


func _on_ButtonUp_pressed():
	print("move up")
	_start_moving(DIRECTION.UP)


func _on_ButtonRight_pressed():
	print("move right")
	_start_moving(DIRECTION.RIGHT)


func _on_ButtonDown_pressed():
	print("move down")
	_start_moving(DIRECTION.DOWN)
