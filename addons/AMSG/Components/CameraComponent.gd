extends Node
class_name CameraComponent


@export var networking_path : NodePath
@onready var networking = get_node(networking_path) 
#####################################
#Refrences
@export var character_movement_component : NodePath
@export var camera_path : NodePath
@export var spring_arm_path : NodePath

@onready var SpringArm = get_node(spring_arm_path)
@onready var Camera = get_node(camera_path)
@onready var PlayerRef = get_node(character_movement_component)
@onready var HObject = SpringArm
@onready var VObject = SpringArm
#####################################
var CameraHOffset := 0.0
@export var view_angle : Global.view_angle = Global.view_angle.right_shoulder:
	get: return view_angle
	set(Newview_angle):
#		if view_mode == Global.view_mode.first_person:
#			return
		view_angle = Newview_angle
		if Camera:
			match Newview_angle:
				Global.view_angle.right_shoulder:
					CameraHOffset = 0.45
					update_camera_offset()
				Global.view_angle.left_shoulder:
					CameraHOffset = -0.45
					update_camera_offset()
				Global.view_angle.head:
					CameraHOffset = 0.0
					update_camera_offset()

			
@export var view_mode = Global.view_mode :
	get: return view_mode
	set(Newview_mode):
		view_mode = Newview_mode
		if VObject:
			VObject.rotation.x = 0.0
		if SpringArm:
			match view_mode:
				Global.view_mode.first_person:
					view_angle = Global.view_angle.head
					PlayerRef.rotation_mode = Global.rotation_mode.looking_direction
					SpringArm.spring_length = -0.4
					VObject = Camera
				Global.view_mode.third_person:
					SpringArm.spring_length = 1.75
					VObject = SpringArm


@export var mouse_sensitvity : float = 0.01
var camera_h : float = 0
var camera_v : float = 0
@export var camera_vertical_min = -90
@export var camera_vertical_max =90
var acceleration_h = 10
var acceleration_v = 10

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Camera.current = networking.is_local_authority()
	

func _input(event):
	if event is InputEventMouseMotion:
		camera_h += -event.relative.x * mouse_sensitvity
		camera_v += -event.relative.y * mouse_sensitvity
		

func _physics_process(delta):
	camera_v = clamp(camera_v,deg_to_rad(camera_vertical_min),deg_to_rad(camera_vertical_max))
	HObject.rotation.y = lerp(HObject.rotation.y,camera_h,delta * acceleration_h)
	VObject.rotation.x = lerp(VObject.rotation.x,camera_v,delta * acceleration_v)
	
	match PlayerRef.rotation_mode:
		Global.rotation_mode.aiming:
			if PlayerRef.gait == Global.gait.sprinting: # character can't sprint while aiming
				PlayerRef.gait = Global.gait.running
			smooth_fov(60.0)
		Global.rotation_mode.velocity_direction:
			smooth_fov(90.0)
		Global.rotation_mode.looking_direction:
			smooth_fov(90.0)


func update_camera_offset():
	var tween := create_tween()
	tween.tween_property(Camera,"h_offset",CameraHOffset,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

var changing_view := false
func smooth_fov(current_fov:float):
	if changing_view:
		return
	changing_view=true
	var tween := create_tween()
	tween.tween_property(Camera,"fov",current_fov,0.1)
	tween.tween_callback(func(): changing_view=false)
