extends Node3D

#####################################
#Refrences
@onready var PlayerRef = get_parent()
#####################################

@export var ViewMode = GlobalEnums.ViewMode
@export var MouseSensitvity = 0.01
var camere_h = 0
var camere_v = 0
@export var camere_vertical_min = -90
@export var camere_vertical_max =90
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
		camere_h += -event.relative.x * MouseSensitvity
		camere_v += event.relative.y * MouseSensitvity

func _physics_process(delta):
	camere_v = clamp(camere_v,deg2rad(camere_vertical_min),deg2rad(camere_vertical_max))
	
	var mesh_front = get_node("../Armature").transform.basis.z
	
	var auto_rotate_speed = (PI - mesh_front.angle_to($h.transform.basis.z)) * get_parent().linear_velocity.length() * rot_speed_multiplier
	
	if $mouse_control_stay_delay.is_stopped():
		#FOLLOW CAMERA
		$h.rotation.y = lerp_angle($h.rotation.y,get_node("../Armature").transform.basis.get_euler().y,delta * auto_rotate_speed)
		camere_h = $h.rotation.y
	else:
		#MOUSE CAMERA
		$h.rotation.y = lerp($h.rotation.y,camere_h,delta * acceleration_h)
	
	$h/v.rotation.x = lerp($h/v.rotation.x,camere_v,delta * acceleration_v)

func OnViewModeChanged(NewViewMode):
	ViewMode = NewViewMode
	if ViewMode == GlobalEnums.ViewMode.ThirdPerson:
		if PlayerRef.RotationMode == GlobalEnums.RotationMode.VelocityDirection || PlayerRef.RotationMode == GlobalEnums.RotationMode.LookingDirection:
			PlayerRef.OnRotationModeChanged(PlayerRef.DesiredRotationMode) 
	elif ViewMode == GlobalEnums.ViewMode.FirstPerson:
		if PlayerRef.RotationMode == GlobalEnums.RotationMode.VelocityDirection:
			PlayerRef.OnRotationModeChanged(GlobalEnums.RotationMode.LookingDirection) 
	
