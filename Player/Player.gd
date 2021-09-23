extends CharacterBody3D




#####################################
#Refrences
@onready var AnimRef = $AnimationTree
@onready var CameraRef = $CameraRoot
#####################################







#####################################
#Movement Settings


@export var gravity = 9.8
var air_time = 0.0
const BONUS_GRAVITY = 2.0
@export var jump_magnitude = 5

@export var roll_magnitude = 17
@export var angular_acceleration = 7

@export var DesiredRotationMode = GlobalEnums.RotationMode
@export var DesiredGait = GlobalEnums.Gait
@export var DesiredStance = GlobalEnums.Stance
#####################################






#####################################
#Controls Settings
@export var OnePressJump = false
@export var UsingSprintToggle = false
#####################################







#####################################
#for logic #it is better not to change it if you don't want to break the system / only change it if you want to redesign the system
var ActualAcceleration
var InputAcceleration :Vector3
@export var MaxAcceleration = 15.0
var vertical_velocity = 0

var InputSpeed = 0
var ActualSpeed = 0

var IsMoving :bool = false
var InputIsMoving :bool = false

var AimRate_H :float

var direction = Vector3.FORWARD



var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO
var aim_turn = 0

var TargetRotation = Vector3.ZERO
var LastVelocityRotation = Vector3.ZERO
var LastMovementInputRotation = Vector3.ZERO

var CurrentMovementData = {
	Walk_Speed = 1.75, 
	Run_Speed = 3.75, 
	Sprint_Speed = 6.5,
	Movement_Curve = preload("res://FakeCurve.tres"), 
	Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
}



#status
var MovementState = GlobalEnums.MovementState.Grounded
var PrevMovementState = GlobalEnums.MovementState.None
var MovementAction = GlobalEnums.MovementAction.LowMantle
var RotationMode = GlobalEnums.RotationMode.LookingDirection
var Gait = GlobalEnums.Gait.Walking
var AllowedGait = GlobalEnums.Gait
var Stance = GlobalEnums.Stance.Standing
var OverlayState = GlobalEnums.OverlayState.Default

#####################################


func _ready():
	CurrentMovementData = MovementData.Normal.LookingDirection.Standing
	
	#Update states to use the initial desired values.
	OnGaitChanged(DesiredGait)
	OnRotationModeChanged(DesiredRotationMode)
	OnOverlayStateChanged(OverlayState)
	TargetRotation = $Armature.get_rotation()
	LastVelocityRotation = $Armature.get_rotation()
	LastMovementInputRotation = $Armature.get_rotation()
	
func _input(event):
	if event is InputEventMouseMotion: 
		aim_turn = -event.relative.x * 0.015
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if event.is_action_pressed("sprint"):
			Gait = GlobalEnums.Gait.Walking if Gait == GlobalEnums.Gait.Sprinting else GlobalEnums.Gait.Sprinting 
	else:
		Gait = GlobalEnums.Gait.Sprinting if Input.is_action_pressed("sprint") else GlobalEnums.Gait.Walking 
		
	
	if is_on_floor():
		if !AnimRef.get("parameters/roll/active"):
			#------------------ Jump ------------------#
			if OnePressJump == true:
				if Input.is_action_just_pressed("jump"):
					vertical_velocity = jump_magnitude
			else:
				if Input.is_action_pressed("jump"):
					vertical_velocity = jump_magnitude
			#------------------ Roll ------------------#
			if event.is_action_pressed("crouch"):
				roll()
	
		

	
func _physics_process(delta):
	SetEssentialValues(delta)
	Debug()
	match MovementState:
		GlobalEnums.MovementState.None:
			pass
		GlobalEnums.MovementState.Grounded:
			UpdateCharacterMovement()
			UpdateGroundedRotation()
		GlobalEnums.MovementState.In_Air:
			pass
		GlobalEnums.MovementState.Mantling:
			pass
		GlobalEnums.MovementState.Ragdoll:
			pass
	
	#------------------ roll control ------------------#
#	if !$roll_timer.is_stopped():
#		MaxAcceleration = 3.5
#	else:
#		MaxAcceleration = 15
	#------------------ Aim ------------------#
	if Input.is_action_pressed("aim"):
		if !AnimRef.get("parameters/roll/active"):
			AnimRef.set("parameters/aim_transition/current",0)
	else:
		AnimRef.set("parameters/aim_transition/current",1)
	
	#------------------ Movement ------------------#
	
	
	var h_rot = $CameraRoot/h.transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
				0,
				Input.get_action_strength("forward") - Input.get_action_strength("back"))
		strafe_dir = direction
		direction = direction.rotated(Vector3.UP,h_rot).normalized()
		if Gait == GlobalEnums.Gait.Sprinting :
			AddMovementInput(direction, CurrentMovementData.Run_Speed ,delta)
		else:
			AddMovementInput(direction, CurrentMovementData.Walk_Speed ,delta)
			
	else:
		AddMovementInput(direction, 0.0 ,delta)
		strafe_dir = Vector3.ZERO
		if AnimRef.get("parameters/aim_transition/current") == 0:
			direction = $CameraRoot/h.transform.basis.z
			
	
	
	
	#------------------ Gravity ------------------#
	if !is_on_floor():
		air_time += delta
		vertical_velocity -= (gravity + gravity * air_time * BONUS_GRAVITY) * delta
		#vertical_velocity -= gravity * delta * (5 if vertical_velocity > 0 else 1) | Another Formula (More Intense)
	else:
		air_time = 0.0
#		if vertical_velocity < -20:
#			roll()
		vertical_velocity = 0
	
	
	#------------------ Rotate Character Mesh ------------------#
	if AnimRef.get("parameters/aim_transition/current") == 1:
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, atan2(direction.x , direction.z), delta * angular_acceleration)
	else:
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, h_rot, delta * angular_acceleration)
		
		
	strafe.x = lerp(strafe.x,strafe_dir.x ,delta * MaxAcceleration)
	strafe.y = lerp(strafe.y,strafe_dir.y,delta * MaxAcceleration)
	strafe.z = lerp(strafe.z,strafe_dir.z + aim_turn,delta * MaxAcceleration)
	
	AnimRef.set("parameters/strafe/blend_position",Vector2(-strafe.x,strafe.z))
	
	#------------------ blend the animation with the velocity ------------------#
	#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
	var iw_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
	var wr_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)

	if ActualSpeed <= CurrentMovementData.Walk_Speed:
		AnimRef.set("parameters/IWR_blend/blend_amount" , iw_blend)
	else:
		AnimRef.set("parameters/IWR_blend/blend_amount" , wr_blend)
		
	
	
	#------------------ Reset Values ------------------#
	aim_turn = 0




func roll():
	AnimRef.set("parameters/roll/active",true)
	$roll_timer.start()
	linear_velocity = (direction - get_floor_normal()) * roll_magnitude









#------------------ Movement Values Settings ------------------#
#you could play with the values to achieve different movement settings

var MovementData = {
	Normal = {
		LookingDirection = {
			Standing = {
				Walk_Speed = 1.75, 
				Run_Speed = 3.75, 
				Sprint_Speed = 6.5,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			},

			Crouching = {
				Walk_Speed = 1.5, 
				Run_Speed = 2, 
				Sprint_Speed = 3,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			}
		},
		
		
		
		
		
		VelocityDirection = {
			Standing = {
				Walk_Speed = 1.75, 
				Run_Speed = 3.75, 
				Sprint_Speed = 6.5,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			},

			Crouching = {
				Walk_Speed = 1.5, 
				Run_Speed = 2, 
				Sprint_Speed = 3,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			}
		},
		
		
		
		
		
		
		Aiming = {
			Standing = {
				Walk_Speed = 1.65, 
				Run_Speed = 3.75, 
				Sprint_Speed = 6.5,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			},

			Crouching = {
				Walk_Speed = 1.5, 
				Run_Speed = 2, 
				Sprint_Speed = 3,
				Movement_Curve = preload("res://FakeCurve.tres"), 
				Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
			}
		}
	}
}



func OnGaitChanged(NewGait):
	Gait = NewGait
func OnRotationModeChanged(NewRotationMode):
	RotationMode = NewRotationMode
	if RotationMode == GlobalEnums.RotationMode.VelocityDirection:
		if CameraRef.ViewMode == GlobalEnums.ViewMode.FirstPerson:
			CameraRef.OnViewModeChanged(GlobalEnums.ViewMode.ThirdPerson)
func OnOverlayStateChanged(NewOverlayState):
	OverlayState = NewOverlayState












#These values represent how the capsule is moving,
#and therefore are essential for any data driven animation system.
#They are also used throughout the system for various functions, so I found it is easiest to manage them all in one place.
var PrevPosition :Vector3
var PrevVelocity :Vector3
var PrevAimRate_H :float
func SetEssentialValues(delta): 
	
	#
	ActualAcceleration = (linear_velocity - PrevVelocity) / (MaxAcceleration * delta)
	PrevVelocity = linear_velocity
	#
	
	#
	ActualSpeed = (((position - PrevPosition) / delta) * Vector3(1.0,0.0,1.0)).length()
	PrevPosition = position
	#
	
	#
	AimRate_H = abs(($CameraRoot/h.rotation.y - PrevAimRate_H) / delta)
	PrevAimRate_H = $CameraRoot/h.rotation.y
	#
	
	if IsMoving:
		pass
		#needs revision
		#LastVelocityRotation.rotated(linear_velocity.normalized(),1.0)
	
	#This represents the speed the camera is rotating left to right. 
	
	

func UpdateCharacterMovement():
	pass
func UpdateGroundedRotation():
	pass
			
			
func Debug():
	$Status/Label.text = "InputSpeed : %s" % InputSpeed
	$Status/Label2.text = "ActualSpeed : %s" % ActualSpeed

func AddMovementInput(direction: Vector3, Speed: float , delta):
	linear_velocity.x = lerp(linear_velocity.x, direction.x * Speed, MaxAcceleration * delta) 
	linear_velocity.y = lerp(linear_velocity.y, vertical_velocity - get_floor_normal().y  ,MaxAcceleration * delta) 
	linear_velocity.z = lerp(linear_velocity.z, direction.z * Speed,MaxAcceleration * delta) 
	move_and_slide()
	InputSpeed = Speed
	InputIsMoving = Speed > 0.0
	InputAcceleration = Speed * MaxAcceleration * direction
	
	

func GetAllowedGait():
	pass
