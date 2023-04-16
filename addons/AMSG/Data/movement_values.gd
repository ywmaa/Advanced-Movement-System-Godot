extends Resource
class_name movement_values

@export var walk_speed : float = 1.75
@export var run_speed : float = 3.75
@export var sprint_speed : float = 6.5

@export var walk_acceleration : float = 20.0
@export var run_acceleration : float = 20.0
@export var sprint_acceleration : float = 20.0

@export var idle_rotation_rate : float = 0.5
@export var walk_rotation_rate : float = 4.0
@export var run_rotation_rate : float = 5.0
@export var sprint_rotation_rate : float = 20.0



func _init(_walk_speed: float = walk_speed, _run_speed: float = run_speed, _sprint_speed: float = sprint_speed,\
	_walk_acceleration : float = walk_acceleration, _run_acceleration : float = run_acceleration, _sprint_acceleration : float = sprint_acceleration,\
	_idle_rotation_rate : float = idle_rotation_rate, _walk_rotation_rate : float = walk_rotation_rate, _run_rotation_rate : float = run_rotation_rate, _sprint_rotation_rate : float = sprint_rotation_rate):
	walk_speed = _walk_speed
	run_speed = _run_speed
	sprint_speed = _sprint_speed

	walk_acceleration = _walk_acceleration
	run_acceleration = _run_acceleration
	sprint_acceleration = _sprint_acceleration

	idle_rotation_rate = _idle_rotation_rate
	walk_rotation_rate = _walk_rotation_rate
	run_rotation_rate = _run_rotation_rate
	sprint_rotation_rate = _sprint_rotation_rate
