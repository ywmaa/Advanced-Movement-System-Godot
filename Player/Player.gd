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

#Movement Values Settings
#you could play with the values to achieve different movement settings

var MovementData = {
	Normal = {
		LookingDirection = {
			Standing = {
				Walk_Speed = 1.75,
				Run_Speed = 3.75,
				Sprint_Speed = 6.5,
				
				Walk_Acceleration = 20.0,
				Run_Acceleration = 20.0,
				Sprint_Acceleration = 7.5,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				Walk_Acceleration = 25.0,
				Run_Acceleration = 25.0,
				Sprint_Acceleration = 5.0,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			}
		},
		
		
		
		
		
		VelocityDirection = {
			Standing = {
				Walk_Speed = 1.75,
				Run_Speed = 3.75,
				Sprint_Speed = 6.5,
				
				Walk_Acceleration = 20.0,
				Run_Acceleration = 20.0,
				Sprint_Acceleration = 7.5,
				
				idle_Rotation_Rate = 5.0,
				Walk_Rotation_Rate = 8.0,
				Run_Rotation_Rate = 12.0,
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				Walk_Acceleration = 25.0,
				Run_Acceleration = 25.0,
				Sprint_Acceleration = 5.0,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			}
		},
		
		
		
		
		
		
		Aiming = {
			Standing = {
				Walk_Speed = 1.65,
				Run_Speed = 3.75,
				Sprint_Speed = 6.5,
				
				Walk_Acceleration = 20.0,
				Run_Acceleration = 20.0,
				Sprint_Acceleration = 7.5,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				Walk_Acceleration = 25.0,
				Run_Acceleration = 25.0,
				Sprint_Acceleration = 5.0,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			}
		}
	}
}
#####################################






#####################################
#Controls Settings
@export var OnePressJump = false
@export var UsingSprintToggle = false
#####################################







#####################################
#for logic #it is better not to change it if you don't want to break the system / only change it if you want to redesign the system
var ActualAcceleration :Vector3
var InputAcceleration :Vector3

var vertical_velocity = 0

var InputSpeed = 0
var ActualSpeed = 0

var IsMoving :bool = false
var InputIsMoving :bool = false

var AimRate_H :float

var direction = Vector3.FORWARD
var h_rotation


#var TargetRotation = Vector3.ZERO
#var LastVelocityRotation = Vector3.ZERO
#var LastMovementInputRotation = Vector3.ZERO

var CurrentMovementData = {
	Walk_Speed = 1.75,
	Run_Speed = 3.75,
	Sprint_Speed = 6.5,

	Walk_Acceleration = 15.0,
	Run_Acceleration = 15.0,
	Sprint_Acceleration = 15.0,

	idle_Rotation_Rate = 0.5,
	Walk_Rotation_Rate = 4.0,
	Run_Rotation_Rate = 5.0,
	Sprint_Rotation_Rate = 20.0,
}


#status
var MovementState = GlobalEnums.MovementState.Grounded
var PrevMovementState = GlobalEnums.MovementState.Grounded
var MovementAction = GlobalEnums.MovementAction.None
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
	
func _input(event):
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if event.is_action_pressed("sprint"):
			Gait = GlobalEnums.Gait.Walking if Gait == GlobalEnums.Gait.Sprinting else GlobalEnums.Gait.Sprinting
	else:
		if Input.is_action_pressed("sprint"):
			Gait = GlobalEnums.Gait.Sprinting
		elif Input.is_action_pressed("run"):
			Gait = GlobalEnums.Gait.Running 
		else:
			Gait = GlobalEnums.Gait.Walking
	
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
	h_rotation = $CameraRoot/h.transform.basis.get_euler().y
	SetEssentialValues(delta)
	Debug()
	match MovementState:
		GlobalEnums.MovementState.None:
			pass
		GlobalEnums.MovementState.Grounded:
			#------------------ Rotate Character Mesh ------------------#
			UpdateGroundedRotation(delta)
		GlobalEnums.MovementState.In_Air:
			#------------------ Rotate Character Mesh In Air ------------------#
			match RotationMode:
					GlobalEnums.RotationMode.VelocityDirection:
						SmoothCharacterRotation($Armature.rotation if ActualSpeed > 1.0 else linear_velocity ,0.0,5.0,delta)
					GlobalEnums.RotationMode.LookingDirection:
						SmoothCharacterRotation($Armature.rotation if ActualSpeed > 1.0 else linear_velocity ,0.0,5.0,delta)
					GlobalEnums.RotationMode.Aiming:
						SmoothCharacterRotation($CameraRoot/h.transform.basis.z ,0.0,15.0,delta)
			#------------------ Mantle Check ------------------#
			if InputIsMoving == true:
				MantleCheck()

			
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
	
	

	
	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
			0,
			Input.get_action_strength("forward") - Input.get_action_strength("back"))
		direction = direction.rotated(Vector3.UP,h_rotation).normalized()
		if Gait == GlobalEnums.Gait.Sprinting :
			AddMovementInput(direction, CurrentMovementData.Sprint_Speed,CurrentMovementData.Sprint_Acceleration ,delta)
		elif Gait == GlobalEnums.Gait.Running:
			AddMovementInput(direction, CurrentMovementData.Run_Speed,CurrentMovementData.Run_Acceleration ,delta)
		else:
			AddMovementInput(direction, CurrentMovementData.Walk_Speed,CurrentMovementData.Walk_Acceleration ,delta)
	else:
		AddMovementInput(direction, 0.0 , CurrentMovementData.Walk_Acceleration,delta)
			
	
	
	
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
	
	
	
	#------------------ blend the animation with the velocity ------------------#
	#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
	var iw_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
	var wr_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)

	if ActualSpeed <= CurrentMovementData.Walk_Speed:
		AnimRef.set("parameters/IWR_blend/blend_amount" , iw_blend)
	else:
		AnimRef.set("parameters/IWR_blend/blend_amount" , wr_blend)
		
	




func roll():
	AnimRef.set("parameters/roll/active",true)
	$roll_timer.start()
	linear_velocity = (direction - get_floor_normal()) * roll_magnitude





func OnGaitChanged(NewGait):
	Gait = NewGait
func OnRotationModeChanged(NewRotationMode):
	RotationMode = NewRotationMode
	if RotationMode == GlobalEnums.RotationMode.VelocityDirection:
		if CameraRef.ViewMode == GlobalEnums.ViewMode.FirstPerson:
			CameraRef.OnViewModeChanged(GlobalEnums.ViewMode.ThirdPerson)
	UpdateCharacterMovement()
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
	AimRate_H = abs(($CameraRoot/h.rotation.y - PrevAimRate_H) / delta)
	PrevAimRate_H = $CameraRoot/h.rotation.y
	#
	
func UpdateCharacterMovement():
	#------------------ Update Movement Values ------------------#
	match RotationMode:
		GlobalEnums.RotationMode.VelocityDirection:
			match Stance:
				GlobalEnums.Stance.Standing:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Standing
				GlobalEnums.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Crouching
					
					
		GlobalEnums.RotationMode.LookingDirection:
			match Stance:
				GlobalEnums.Stance.Standing:
					CurrentMovementData = MovementData.Normal.LookingDirection.Standing
				GlobalEnums.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.LookingDirection.Crouching
					
					
		GlobalEnums.RotationMode.Aiming:
			match Stance:
				GlobalEnums.Stance.Standing:
					CurrentMovementData = MovementData.Normal.Aiming.Standing
				GlobalEnums.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.Aiming.Crouching
	



func Debug():
	$Status/Label.text = "InputSpeed : %s" % InputSpeed
	$Status/Label2.text = "ActualSpeed : %s" % ActualSpeed
func AddMovementInput(direction: Vector3, Speed: float , Acceleration: float, delta):
	linear_velocity.x = lerp(linear_velocity.x, direction.x * Speed, Acceleration * delta)
	linear_velocity.y = lerp(linear_velocity.y, vertical_velocity - get_floor_normal().y  ,Acceleration * delta)
	linear_velocity.z = lerp(linear_velocity.z, direction.z * Speed,Acceleration * delta)
	move_and_slide()
	InputSpeed = Speed
	InputIsMoving = Speed > 0.0
	InputAcceleration = Speed * Acceleration * direction
	
	#
	ActualAcceleration = (linear_velocity - PrevVelocity) / (Acceleration * delta)
	PrevVelocity = linear_velocity
	#
	
	#
	ActualSpeed = (((position - PrevPosition) / delta) * Vector3(1.0,0.0,1.0)).length()
	PrevPosition = position
	#
	
func UpdateGroundedRotation(delta):
	match MovementAction:
		GlobalEnums.MovementAction.None:
			if (IsMoving and InputIsMoving) or ActualSpeed > 1.5:
				match RotationMode:
					GlobalEnums.RotationMode.VelocityDirection:
						SmoothCharacterRotation(linear_velocity  ,800.0,CalcGroundedRotationRate(),delta)
					GlobalEnums.RotationMode.LookingDirection:
						if Gait == GlobalEnums.Gait.Sprinting:
							SmoothCharacterRotation(linear_velocity,500.0,CalcGroundedRotationRate(),delta)
						else:
							
							SmoothCharacterRotation($CameraRoot/h.transform.basis.z ,500.0,CalcGroundedRotationRate(),delta)
					GlobalEnums.RotationMode.Aiming:
						SmoothCharacterRotation($CameraRoot/h.transform.basis.z ,1000.0,20.0,delta)
			else:
				if $CameraRoot.ViewMode == GlobalEnums.ViewMode.FirstPerson or RotationMode == GlobalEnums.RotationMode.Aiming:
					#------------------ Limit Rotation ------------------#
					var RotationDifferenceNormalized = ($Armature.rotation.y - atan2($CameraRoot/h.transform.basis.z.x,$CameraRoot/h.transform.basis.z.z)).normalized()
					if not -100 <= RotationDifferenceNormalized >= 100: #Value is not InRange (-100,100)
						SmoothCharacterRotation(Vector3(0.0,RotationDifferenceNormalized + -100,0.0) if RotationDifferenceNormalized > 0.0 else  Vector3(0.0,RotationDifferenceNormalized + 100,0.0) ,0.0,20.0,delta)
					
		GlobalEnums.MovementAction.Rolling:
			if InputIsMoving == true:
				SmoothCharacterRotation(InputAcceleration ,0.0,2.0,delta)
			

func SmoothCharacterRotation(Target:Vector3,Targetlerpspeed,nodelerpspeed,delta):
	
	var TargetRotation :Vector3
	TargetRotation.z = lerp(TargetRotation.z,Target.z,delta * Targetlerpspeed)
	TargetRotation.x = lerp(TargetRotation.x,Target.x,delta * Targetlerpspeed)
	$Armature.rotation.y = lerp_angle($Armature.rotation.y, atan2(TargetRotation.x,TargetRotation.z) , delta * nodelerpspeed)
	
func CalcGroundedRotationRate():
	
	if InputIsMoving == true:
		match Gait:
			GlobalEnums.Gait.Walking:
				return lerp(CurrentMovementData.idle_Rotation_Rate,CurrentMovementData.Walk_Rotation_Rate, ActualSpeed) * clamp(AimRate_H,1.0,3.0)
			GlobalEnums.Gait.Running:
				return lerp(CurrentMovementData.Walk_Rotation_Rate,CurrentMovementData.Run_Rotation_Rate, ActualSpeed) * clamp(AimRate_H,1.0,3.0)
			GlobalEnums.Gait.Sprinting:
				return lerp(CurrentMovementData.Run_Rotation_Rate,CurrentMovementData.Sprint_Rotation_Rate, ActualSpeed) * clamp(AimRate_H,1.0,3.0)
	else:
		return CurrentMovementData.idle_Rotation_Rate * clamp(AimRate_H,1.0,3.0)
		

func MantleCheck():
	pass
