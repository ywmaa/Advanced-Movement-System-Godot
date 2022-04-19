extends Node3D
class_name CameraRoot
#####################################
#Refrences
@onready var SpringArm = $SpringArm3D
@onready var Camera = $SpringArm3D/Camera
@onready var PlayerRef = get_parent()
@onready var HObject = $SpringArm3D
@onready var VObject = $SpringArm3D
#####################################
var CameraHOffset := 0.0
@export var view_angle = Global.view_angle :
	get: return view_angle
	set(Newview_angle):
		view_angle = Newview_angle
		if Camera:
			if Newview_angle == Global.view_angle.right_shoulder and view_mode != Global.view_mode.first_person:
				CameraHOffset = 0.45
			elif Newview_angle == Global.view_angle.left_shoulder and view_mode != Global.view_mode.first_person:
				CameraHOffset = -0.45
			elif Newview_angle == Global.view_angle.head:
				CameraHOffset = 0.0
			
@export var view_mode = Global.view_mode :
	get: return view_mode
	set(Newview_mode):
		view_mode = Newview_mode
		if VObject:
			VObject.rotation.x = 0.0
		if SpringArm:
			if view_mode == Global.view_mode.first_person:
				view_angle = Global.view_angle.head
				$SpringArm3D.spring_length = -0.4
				VObject = $SpringArm3D/Camera
				if PlayerRef.rotation_mode == Global.rotation_mode.velocity_direction:
					PlayerRef.rotation_mode = Global.rotation_mode.looking_direction
			elif view_mode == Global.view_mode.third_person:
				$SpringArm3D.spring_length = 1.75
				VObject = $SpringArm3D
	
@export var mouse_sensitvity : float = 0.01
var camera_h = 0
var camera_v = 0
@export var camera_vertical_min = -90
@export var camera_vertical_max =90
var acceleration_h = 10
var acceleration_v = 10

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camera_h += -event.relative.x * mouse_sensitvity
		camera_v += -event.relative.y * mouse_sensitvity
		
	
		
	

func _physics_process(delta):
	if $SpringArm3D/Camera.h_offset != CameraHOffset:
		$SpringArm3D/Camera.h_offset = lerp($SpringArm3D/Camera.h_offset,CameraHOffset,delta)
		
	camera_v = clamp(camera_v,deg2rad(camera_vertical_min),deg2rad(camera_vertical_max))
	HObject.rotation.y = lerp(HObject.rotation.y,camera_h,delta * acceleration_h)
	
	

	VObject.rotation.x = lerp(VObject.rotation.x,camera_v,delta * acceleration_v)

