extends Node3D

#####################################
#Refrences
@onready var PlayerRef = get_parent()
#####################################

@export var ViewMode = Global.ViewMode :
	get: ViewMode
	set(NewViewMode):
		ViewMode = NewViewMode
		if ViewMode == Global.ViewMode.FirstPerson:
			if PlayerRef.RotationMode == Global.RotationMode.VelocityDirection:
				PlayerRef.RotationMode = Global.RotationMode.LookingDirection
	
@export var MouseSensitvity = 0.01
var camera_h = 0
var camera_v = 0
@export var camera_vertical_min = -90
@export var camera_vertical_max =90
var acceleration_h = 10
var acceleration_v = 10
@export var rot_speed_multiplier = 0.15 #reduce this to make the rotation radius larger
@export var FollowCameraEnabled = true
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$h/v/Camera.add_exception(get_parent())


func _input(event):
	if event is InputEventMouseMotion:
		if FollowCameraEnabled == true:
			$mouse_control_stay_delay.start()
		camera_h += -event.relative.x * MouseSensitvity
		camera_v += event.relative.y * MouseSensitvity

func _physics_process(delta):
	camera_v = clamp(camera_v,deg2rad(camera_vertical_min),deg2rad(camera_vertical_max))
	
	var mesh_front = get_node("../Armature").transform.basis.z
	
	var auto_rotate_speed = (PI - mesh_front.angle_to($h.transform.basis.z)) * get_parent().motion_velocity.length() * rot_speed_multiplier
	
	if $mouse_control_stay_delay.is_stopped() and FollowCameraEnabled == true:
		#FOLLOW CAMERA
		$h.rotation.y = lerp_angle($h.rotation.y,get_node("../Armature").transform.basis.get_euler().y,delta * auto_rotate_speed)
		camera_h = $h.rotation.y
	else:
		#MOUSE CAMERA
		$h.rotation.y = lerp($h.rotation.y,camera_h,delta * acceleration_h)
	
	$h/v.rotation.x = lerp($h/v.rotation.x,camera_v,delta * acceleration_v)
