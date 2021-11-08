extends Node3D

#####################################
#Refrences
@onready var SpringArm = $SpringArm3D
@onready var Camera = $SpringArm3D/Camera
@onready var PlayerRef = get_parent()
@onready var HObject = $SpringArm3D
@onready var VObject = $SpringArm3D
#####################################
var CameraHOffset = 0.0
@export var ViewAngle = Global.ViewAngle :
	get: return ViewAngle
	set(NewViewAngle):
		ViewAngle = NewViewAngle
		if Camera:
			if NewViewAngle == Global.ViewAngle.RightShoulder and ViewMode != Global.ViewMode.FirstPerson:
				CameraHOffset = 0.45
			elif NewViewAngle == Global.ViewAngle.LeftShoulder and ViewMode != Global.ViewMode.FirstPerson:
				CameraHOffset = -0.45
			elif NewViewAngle == Global.ViewAngle.Head:
				CameraHOffset = 0.0
			
@export var ViewMode = Global.ViewMode :
	get: return ViewMode
	set(NewViewMode):
		ViewMode = NewViewMode
		if VObject:
			VObject.rotation.x = 0.0
		if SpringArm:
			if ViewMode == Global.ViewMode.FirstPerson:
				ViewAngle = Global.ViewAngle.Head
				$SpringArm3D.spring_length = -0.4
				VObject = $SpringArm3D/Camera
				if PlayerRef.RotationMode == Global.RotationMode.VelocityDirection:
					PlayerRef.RotationMode = Global.RotationMode.LookingDirection
			elif ViewMode == Global.ViewMode.ThirdPerson:
				$SpringArm3D.spring_length = 2.5
				VObject = $SpringArm3D
	
@export var MouseSensitvity = 0.01
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
		camera_h += -event.relative.x * MouseSensitvity
		camera_v += -event.relative.y * MouseSensitvity
		
	
		
	

func _physics_process(delta):
	if $SpringArm3D/Camera.h_offset != CameraHOffset:
		$SpringArm3D/Camera.h_offset = lerp($SpringArm3D/Camera.h_offset,CameraHOffset,delta)
		
	camera_v = clamp(camera_v,deg2rad(camera_vertical_min),deg2rad(camera_vertical_max))
	HObject.rotation.y = lerp(HObject.rotation.y,camera_h,delta * acceleration_h)
	
	

	VObject.rotation.x = lerp(VObject.rotation.x,camera_v,delta * acceleration_v)

