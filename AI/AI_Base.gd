extends "res://Character/CharacterMovement_Base.gd"

#####################################
#Refrences
@onready var CameraRef = $CameraRoot
#####################################


var h_rotation :float
var v_rotation :float

var direction := Vector3.FORWARD

var PreviousRotationMode 
func _ready():
	super._ready()
	
	
func _physics_process(delta):
	super._physics_process(delta)
	
	
	#------------------ Input Movement ------------------#
	h_rotation = $CameraRoot.HObject.transform.basis.get_euler().y
	v_rotation = $CameraRoot.VObject.transform.basis.get_euler().x

	
	AddMovementInput(Vector3(0.0,0.0,1.0), CurrentMovementData.Walk_Speed,CurrentMovementData.Walk_Acceleration)
	
	#------------------ Look At ------------------#
	match RotationMode:
		Global.RotationMode.VelocityDirection:
			if InputIsMoving:
				IKLookAt(motion_velocity + Vector3(0.0,1.0,0.0))
		Global.RotationMode.LookingDirection:
			IKLookAt(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
		Global.RotationMode.Aiming:
			IKLookAt(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))

