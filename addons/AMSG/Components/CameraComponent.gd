extends Node
class_name CameraComponent
## Script used to control the camera for the player

@export var networking : PlayerNetworkingComponent
#####################################
#Refrences
@export var SpringArm : SpringArm3D
@export var Camera : Camera3D
@export var PlayerRef : CharacterMovementComponent
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

			
@export var view_mode : Global.view_mode = Global.view_mode.third_person :
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


var camera_h : float = 0
var camera_v : float = 0
@export var camera_vertical_min : float = -90
@export var camera_vertical_max : float = 90

## Assign a [camera_values] resource to it and change its values to tweak camera settings
@export var camera_settings : camera_values = camera_values.new()
@export var first_person_camera_bone : BoneAttachment3D
var current_fov : float = 90.0
var acceleration_h = 10
var acceleration_v = 10

var spring_arm_position_relative_to_player : Vector3
func _ready():
	spring_arm_position_relative_to_player = SpringArm.position
	SpringArm.top_level = true

func _physics_process(delta):
	if camera_settings.camera_change_fov_on_speed and PlayerRef.actual_velocity.length() > camera_settings.camera_fov_change_starting_speed:
		smooth_fov(current_fov + clampf((PlayerRef.actual_velocity.length()-camera_settings.camera_fov_change_starting_speed)*(camera_settings.camera_max_fov_change/10.0),0,camera_settings.camera_max_fov_change))

	SpringArm.position = SpringArm.position.lerp((get_parent().global_position + spring_arm_position_relative_to_player) if view_mode == Global.view_mode.third_person else first_person_camera_bone.global_position,(1/camera_settings.camera_inertia) if view_mode == Global.view_mode.third_person else 1.0)
	
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
func smooth_fov(_current_fov:float):
	current_fov = _current_fov
	if changing_view:
		return
	changing_view=true
	var tween := create_tween()
	tween.tween_property(Camera,"fov",current_fov,0.1)
	tween.tween_callback(func(): changing_view=false)
	
	

func smooth_camera_transition(pos:Vector3, look_at:Vector3, duration:float = 1.0 ,ease:Tween.EaseType = Tween.EASE_IN_OUT, trans:Tween.TransitionType = Tween.TRANS_LINEAR):
#	Camera.global_position = Camera.to_global(Camera.global_position)
	Camera.top_level = true
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(Camera,"position",pos,duration).set_ease(ease).set_trans(trans)
	tween.tween_method(func(arr:Array): Camera.look_at_from_position(arr[0],arr[1]),[Camera.position,look_at],[pos,look_at],duration).set_ease(ease).set_trans(trans)
	
var reseting : bool = false
func reset_camera_transition(smooth_transition: bool = true):
	if Camera.top_level == false:
		return
	if smooth_transition:
		
		if reseting == true:
			return
		reseting = true
		Camera.top_level = false
		var tween := create_tween()
		tween.set_parallel()
		tween.tween_property(Camera,"position",Vector3(0,0,SpringArm.spring_length),1.0)
		tween.tween_property(Camera,"rotation",Vector3.ZERO,1.0)
		tween.tween_callback(func(): reseting=false)
		
	else:
		Camera.rotation = Vector3.ZERO
		Camera.top_level = false
