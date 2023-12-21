extends Resource
class_name camera_values


@export var camera_inertia : float = 7.5
@export var camera_change_fov_on_speed : bool = false
@export var camera_max_fov_change : float = 20.0
@export var camera_fov_change_starting_speed : float = 0.0
@export var target_fov : float = 90.0


func _init(_camera_inertia: float = camera_inertia, _camera_change_fov_on_speed: bool = camera_change_fov_on_speed, _camera_max_fov_change: float = camera_max_fov_change,\
	_camera_fov_change_starting_speed : float = camera_fov_change_starting_speed, _target_fov : float = target_fov):
	
	camera_inertia = _camera_inertia
	camera_change_fov_on_speed = _camera_change_fov_on_speed
	camera_max_fov_change = _camera_max_fov_change

	camera_fov_change_starting_speed = _camera_fov_change_starting_speed
	target_fov = _target_fov
