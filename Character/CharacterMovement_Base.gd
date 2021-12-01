extends CharacterBody3D




#####################################
#Refrences
@onready var AnimRef = $AnimationTree
@onready var MeshRef = $Armature
@onready var SkeletonRef = $Armature/Skeleton3D
@onready var CollShapeRef = $CollisionShape3D
@onready var bonker = $CollisionShape3D/HeadBonker
@onready var CameraRoot = $CameraRoot
#####################################



#####################################
#Movement Settings
@export var AI := false

@export var IsFlying := false
@export var gravity := 9.8
var air_time := 0.0
const BONUS_GRAVITY := 2.0

@export var Ragdoll := false :
	get: return Ragdoll
	set(NewRagdoll):
		Ragdoll = NewRagdoll
		if Ragdoll == true:
			SkeletonRef.physical_bones_start_simulation()
		else:
			pass#			SkeletonRef.physical_bones_stop_simulation()


@export var jump_magnitude := 5.0
@export var roll_magnitude := 17.0

var default_height := 2.0
var crouch_height := 1.0

@export var crouch_switch_speed := 5.0 

@export var DesiredRotationMode = Global.RotationMode :
	get: return DesiredRotationMode
	set(NewRotationMode):
		DesiredRotationMode = NewRotationMode
		RotationMode = NewRotationMode

@export var DesiredGait = Global.Gait :
	get: return DesiredGait
	set(NewGait):
		DesiredGait = NewGait
		Gait = NewGait

@export var DesiredStance = Global.Stance :
	get: return DesiredStance
	set(NewStance):
		DesiredStance = NewStance
		Stance = NewStance

@export var DesiredOverlayState = Global.OverlayState :
	get: return DesiredOverlayState
	set(NewOverlayState): 
		DesiredOverlayState = NewOverlayState
		OverlayState = NewOverlayState


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
				
				#Nomral Acceleration
				Walk_Acceleration = 20.0,
				Run_Acceleration = 20.0, 
				Sprint_Acceleration = 7.5,
				
				#Responsive Rotation
				idle_Rotation_Rate = 5.0,
				Walk_Rotation_Rate = 8.0,
				Run_Rotation_Rate = 12.0, 
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				#Responsive Acceleration
				Walk_Acceleration = 25.0,
				Run_Acceleration = 25.0,
				Sprint_Acceleration = 5.0,
				
				#Nomral Rotation
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
#for logic #it is better not to change it if you don't want to break the system / only change it if you want to redesign the system
var ActualAcceleration :Vector3
var InputAcceleration :Vector3

var vertical_velocity := 0.0 

var InputSpeed := 0.0
var ActualSpeed := 0.0

var IsMoving := false
var InputIsMoving := false

var head_bonked := false

var AimRate_H :float


var CurrentMovementData = {
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
}


#status
var MovementState = Global.MovementState.Grounded
var MovementAction = Global.MovementAction.None
var RotationMode = Global.RotationMode.LookingDirection :
	get: return RotationMode
	set(NewRotationMode):
		RotationMode = NewRotationMode
		UpdateCharacterMovement()
var Gait = Global.Gait.Walking :
	get: return Gait
	set(NewGait):
		Gait = NewGait
		UpdateCharacterMovement()
var Stance = Global.Stance.Standing
var OverlayState = Global.OverlayState.Default

func UpdateCharacterMovement():
	#------------------ Update Movement Values ------------------#
	match RotationMode:
		Global.RotationMode.VelocityDirection:
			match Stance:
				Global.Stance.Standing:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Standing
				Global.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Crouching
					
					
		Global.RotationMode.LookingDirection:
			match Stance:
				Global.Stance.Standing:
					CurrentMovementData = MovementData.Normal.LookingDirection.Standing
				Global.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.LookingDirection.Crouching
					
					
		Global.RotationMode.Aiming:
			match Stance:
				Global.Stance.Standing:
					CurrentMovementData = MovementData.Normal.Aiming.Standing
				Global.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.Aiming.Crouching
#####################################
var PrevVelocity :Vector3
var PrevAimRate_H :float
var RotationDifference
func _physics_process(delta):
	head_bonked = bonker.is_colliding()
	#
	AimRate_H = abs(($CameraRoot.HObject.rotation.y - PrevAimRate_H) / delta)
	PrevAimRate_H = $CameraRoot.HObject.rotation.y
	#
	#Debug()
	match MovementState:
		Global.MovementState.None:
			pass
		Global.MovementState.Grounded:
			
			#------------------ Rotate Character Mesh ------------------#
			match MovementAction:
				Global.MovementAction.None:
					if (IsMoving and InputIsMoving) or ActualSpeed > 1.5:
						SmoothCharacterRotation(motion_velocity,CalcGroundedRotationRate(),delta)
				Global.MovementAction.Rolling:
					if InputIsMoving == true:
						SmoothCharacterRotation(InputAcceleration ,2.0,delta)
						
		
		Global.MovementState.In_Air:
			#------------------ Rotate Character Mesh In Air ------------------#
			match RotationMode:
					Global.RotationMode.VelocityDirection: 
						SmoothCharacterRotation(motion_velocity if ActualSpeed > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
					Global.RotationMode.LookingDirection:
						SmoothCharacterRotation(motion_velocity if ActualSpeed > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
					Global.RotationMode.Aiming:
						SmoothCharacterRotation(-$CameraRoot.HObject.transform.basis.z ,15.0,delta)
			#------------------ Mantle Check ------------------#
			if InputIsMoving == true:
				MantleCheck()
		Global.MovementState.Mantling:
			pass
		Global.MovementState.Ragdoll:
			pass
	

	#------------------ Crouch ------------------#
	if head_bonked:
		vertical_velocity = -2
	if Stance == Global.Stance.Crouching:
		bonker.transform.origin.y -= crouch_switch_speed * delta
		CollShapeRef.shape.height -= crouch_switch_speed * delta /2
	elif Stance == Global.Stance.Standing and not head_bonked:
		bonker.transform.origin.y += crouch_switch_speed * delta 
		CollShapeRef.shape.height += crouch_switch_speed * delta /2
		
	bonker.transform.origin.y = clamp(bonker.transform.origin.y,0.5,1.0)
	CollShapeRef.shape.height = clamp(CollShapeRef.shape.height,crouch_height,default_height)
	

	#------------------ Gravity ------------------#
	if IsFlying == false:
		motion_velocity.y =  lerp(motion_velocity.y,vertical_velocity - get_floor_normal().y,delta * gravity)
		move_and_slide()
	if !is_on_floor() and IsFlying == false:
		MovementState = Global.MovementState.In_Air 
		air_time += delta
		vertical_velocity -= (gravity + gravity * air_time * BONUS_GRAVITY) * delta
		#vertical_velocity -= gravity * delta * (5 if vertical_velocity > 0 else 1) | Another Formula (More Intense)
	else:
		MovementState = Global.MovementState.Grounded
		air_time = 0.0
#		if vertical_velocity < -20:
#			roll()
		vertical_velocity = 0
	
	#------------------ blend the animation with the velocity ------------------#
	#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
#	var iw_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
#	var wr_blend = (ActualSpeed - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
#
#	if ActualSpeed <= CurrentMovementData.Walk_Speed:
#		AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , iw_blend)
#	else:
#		AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , wr_blend)

	## Currently using imediate switch because there is a bug in the animation blend
	if InputSpeed > 0.0:
		if Gait == Global.Gait.Sprinting :
			AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 1)
		elif Gait == Global.Gait.Running:
			AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 1)
		else:
			AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 0)
	else:
		AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , -1)
	
	
	






func SmoothCharacterRotation(Target:Vector3,nodelerpspeed,delta):
	MeshRef.rotation.y = lerp_angle(MeshRef.rotation.y, atan2(Target.x,Target.z) , delta * nodelerpspeed)
	
func CalcGroundedRotationRate():
	
	if InputIsMoving == true:
		match Gait:
			Global.Gait.Walking:
				return lerp(CurrentMovementData.idle_Rotation_Rate,CurrentMovementData.Walk_Rotation_Rate, Global.MapRangeClamped(ActualSpeed,0.0,CurrentMovementData.Walk_Speed,0.0,1.0)) * clamp(AimRate_H,1.0,3.0)
			Global.Gait.Running:
				return lerp(CurrentMovementData.Walk_Rotation_Rate,CurrentMovementData.Run_Rotation_Rate, Global.MapRangeClamped(ActualSpeed,CurrentMovementData.Walk_Speed,CurrentMovementData.Run_Speed,1.0,2.0)) * clamp(AimRate_H,1.0,3.0)
			Global.Gait.Sprinting:
				return lerp(CurrentMovementData.Run_Rotation_Rate,CurrentMovementData.Sprint_Rotation_Rate,  Global.MapRangeClamped(ActualSpeed,CurrentMovementData.Run_Speed,CurrentMovementData.Sprint_Speed,2.0,3.0)) * clamp(AimRate_H,1.0,2.5)
	else:
		return CurrentMovementData.idle_Rotation_Rate * clamp(AimRate_H,1.0,3.0)



func IKLookAt(position: Vector3):
	if $LookAtObject:
		$LookAtObject.position = position




func AddMovementInput(direction: Vector3, Speed: float , Acceleration: float):
	if IsFlying == false:
		motion_velocity.x = lerp(motion_velocity.x, direction.x * Speed, Acceleration * get_physics_process_delta_time())
		motion_velocity.z = lerp(motion_velocity.z, direction.z * Speed, Acceleration * get_physics_process_delta_time())
	else:
		set_motion_velocity(get_motion_velocity().lerp(direction * Speed, Acceleration * get_physics_process_delta_time()))
		move_and_slide()
	InputSpeed = Speed
	InputIsMoving = Speed > 0.0
	InputAcceleration = Speed * Acceleration * direction
	
	#
	ActualAcceleration = (motion_velocity - PrevVelocity) / (Acceleration * get_physics_process_delta_time())
	PrevVelocity = motion_velocity
	#

	#
	ActualSpeed = (get_real_velocity() * Vector3(1.0,0.0,1.0)).length()
	#



func MantleCheck():
	pass

func jump():
	vertical_velocity = jump_magnitude

func Debug():
	pass
#	$Status/Label.text = "InputSpeed : %s" % InputSpeed
#	$Status/Label2.text = "ActualSpeed : %s" % ActualSpeed





