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

@export var Tilt := true

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


#Movement Values Settings
#you could play with the values to achieve different movement settings
var Deacceleration := 10.0
var accelerationReducer := 3
var MovementData = {
	Normal = {
		LookingDirection = {
			Standing = {
				Walk_Speed = 1.75,
				Run_Speed = 3.75,
				Sprint_Speed = 6.5,
				
				Walk_Acceleration = 20.0/accelerationReducer,
				Run_Acceleration = 20.0/accelerationReducer,
				Sprint_Acceleration = 7.5/accelerationReducer,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				Walk_Acceleration = 25.0/accelerationReducer,
				Run_Acceleration = 25.0/accelerationReducer,
				Sprint_Acceleration = 5.0/accelerationReducer,
				
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
				Walk_Acceleration = 20.0/accelerationReducer,
				Run_Acceleration = 20.0/accelerationReducer, 
				Sprint_Acceleration = 7.5/accelerationReducer,
				
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
				Walk_Acceleration = 25.0/accelerationReducer,
				Run_Acceleration = 25.0/accelerationReducer,
				Sprint_Acceleration = 5.0/accelerationReducer,
				
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
				
				Walk_Acceleration = 20.0/accelerationReducer,
				Run_Acceleration = 20.0/accelerationReducer,
				Sprint_Acceleration = 7.5/accelerationReducer,
				
				idle_Rotation_Rate = 0.5,
				Walk_Rotation_Rate = 4.0,
				Run_Rotation_Rate = 5.0,
				Sprint_Rotation_Rate = 20.0,
			},

			Crouching = {
				Walk_Speed = 1.5,
				Run_Speed = 2,
				Sprint_Speed = 3,
				
				Walk_Acceleration = 25.0/accelerationReducer,
				Run_Acceleration = 25.0/accelerationReducer,
				Sprint_Acceleration = 5.0/accelerationReducer,
				
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

var vertical_velocity :Vector3 

var InputVelocity :Vector3
var ActualVelocity :Vector3

var tiltVector : Vector3

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
#####################################



#status
var MovementState = Global.MovementState.Grounded
var MovementAction = Global.MovementAction.None
@export var RotationMode = Global.RotationMode :
	get: return RotationMode
	set(NewRotationMode):
		RotationMode = NewRotationMode
		UpdateCharacterMovement()
		
@export var Gait = Global.Gait :
	get: return Gait
	set(NewGait):
		Gait = NewGait
		UpdateCharacterMovement()
@export var Stance = Global.Stance
@export var OverlayState = Global.OverlayState

func UpdateCharacterMovement():
	match RotationMode:
		Global.RotationMode.VelocityDirection:
			if SkeletonRef:
				SkeletonRef.modification_stack.enabled = false
			Tilt = false
			match Stance:
				Global.Stance.Standing:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Standing
				Global.Stance.Crouching:
					CurrentMovementData = MovementData.Normal.VelocityDirection.Crouching
					
					
		Global.RotationMode.LookingDirection:
			if SkeletonRef:
				SkeletonRef.modification_stack.enabled = false #Change to true when Godot fixes the bug.
			Tilt = true
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
			AnimRef.set("parameters/InAir/blend_amount" , 0)
			#------------------ Rotate Character Mesh ------------------#
			match MovementAction:
				Global.MovementAction.None:
					match RotationMode:
							Global.RotationMode.VelocityDirection: 
								if (IsMoving and InputIsMoving) or ActualVelocity.length() > 0.5:
									StopRotatingInPlace() #Moving so stop the rotate in place
									SmoothCharacterRotation(motion_velocity,CalcGroundedRotationRate(),delta)
							Global.RotationMode.LookingDirection:
								if (IsMoving and InputIsMoving) or ActualVelocity.length() > 0.5:
									StopRotatingInPlace() #Moving so stop the rotate in place
									SmoothCharacterRotation(-$CameraRoot.HObject.transform.basis.z if Gait != Global.Gait.Sprinting else motion_velocity,CalcGroundedRotationRate(),delta)
								else:
									if InputIsMoving == false:
										var CameraAngle = rad2deg($CameraRoot.HObject.rotation.y) +180
										var MeshAngle = rad2deg(MeshRef.rotation.y)
										if abs(CameraAngle - MeshAngle) > 90.0:
											if IsRotating == false:
												RotateInPlace(CameraAngle,MeshAngle)
							Global.RotationMode.Aiming:
								if Gait == Global.Gait.Sprinting: # character can't sprint while aiming
									Gait = Global.Gait.Running
								if (IsMoving and InputIsMoving) or ActualVelocity.length() > 0.5:
									StopRotatingInPlace() #Moving so stop the rotate in place
									SmoothCharacterRotation(-$CameraRoot.HObject.transform.basis.z,CalcGroundedRotationRate(),delta)
								else:
									if InputIsMoving == false:
										var CameraAngle = rad2deg($CameraRoot.HObject.rotation.y) +180
										var MeshAngle = rad2deg(MeshRef.rotation.y)
										if abs(CameraAngle - MeshAngle) > 90.0:
											if IsRotating == false:
												RotateInPlace(CameraAngle,MeshAngle)
				Global.MovementAction.Rolling:
					if InputIsMoving == true:
						SmoothCharacterRotation(InputAcceleration ,2.0,delta)
						
		
		Global.MovementState.In_Air:
			#------------------ Rotate Character Mesh In Air ------------------#
			StopRotatingInPlace()
			AnimRef.set("parameters/InAir/blend_amount" , 1)
			match RotationMode:
					Global.RotationMode.VelocityDirection: 
						SmoothCharacterRotation(motion_velocity if ActualVelocity.length() > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
					Global.RotationMode.LookingDirection:
						SmoothCharacterRotation(motion_velocity if ActualVelocity.length() > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
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
		motion_velocity.y =  lerp(motion_velocity.y,vertical_velocity.y - get_floor_normal().y,delta * gravity)
		move_and_slide()
		
	if is_on_floor() and IsFlying == false:
		MovementState = Global.MovementState.Grounded 
		vertical_velocity = -get_floor_normal() * 10
	else:
		MovementState = Global.MovementState.In_Air
		vertical_velocity += Vector3.DOWN * gravity * delta
#		if vertical_velocity < -20:
#			roll()
	if is_on_ceiling():
		vertical_velocity.y = 0
#	#------------------ blend the animation with the velocity ------------------#
	#Blend Animations with Movement
	if RotationMode == Global.RotationMode.VelocityDirection:
		AnimRef.set("parameters/VelocityOrLooking/blend_amount" ,0)
		## Currently using imediate switch because there is a bug in the animation blend
		
		#Speed
		#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
#		var iw_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
#		var wr_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
#		var rs_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Sprint_Speed - CurrentMovementData.Run_Speed)
		
		#Blend
		if InputVelocity.length() > 0.0:
			if Gait == Global.Gait.Sprinting :
				AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 2)
			elif Gait == Global.Gait.Running:
				AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 1)
			else:
				AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , 0)
		else:
			AnimRef.set("parameters/VelocityDirection/IWR_Blend/blend_position" , -1)
	else: #Animation blend for Both looking direction mode and aiming mode
		AnimRef.set("parameters/VelocityOrLooking/blend_amount" ,1)
		
		#Speed
#		var iw_blend = ActualVelocity.length() / CurrentMovementData.Walk_Speed
#		var wr_blend = ActualVelocity.length() / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
#		var rs_blend = ActualVelocity.length() / (CurrentMovementData.Sprint_Speed - CurrentMovementData.Run_Speed)
		
		#Direction
		var MovementDirectionRelativeToCamera = get_real_velocity().normalized().rotated(Vector3.UP,-$CameraRoot.HObject.transform.basis.get_euler().y)
		MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera.x * -MovementDirectionRelativeToCamera.z if abs(MovementDirectionRelativeToCamera.z) > 0.1 else MovementDirectionRelativeToCamera.x #I tried comparing with 0.0 but because of me using a physically calc velocity it will most of the time give value bigger than 0.0 so compare with 0.1 instead
		var IsMovingBackwardRelativeToCamera = false if -get_real_velocity().rotated(Vector3.UP,-$CameraRoot.HObject.transform.basis.get_euler().y).z >= -0.1 else true
		if IsMovingBackwardRelativeToCamera:
			MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera * -1
		
		
		#Blend
		if InputVelocity.length() > 0.0:
			if ActualVelocity.length() <= CurrentMovementData.Walk_Speed :
				AnimRef.set("parameters/LookingDirection/LookingDirectionBlend/blend_position" , Vector2(MovementDirectionRelativeToCamera,-1 if IsMovingBackwardRelativeToCamera else 1))
			elif ActualVelocity.length() <= CurrentMovementData.Run_Speed:
				AnimRef.set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(MovementDirectionRelativeToCamera,-2 if IsMovingBackwardRelativeToCamera else 2))
			elif ActualVelocity.length() <= CurrentMovementData.Sprint_Speed:
				AnimRef.set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,3))
		else:
			AnimRef.set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,0))




func SmoothCharacterRotation(Target:Vector3,nodelerpspeed,delta):
	MeshRef.rotation.y = lerp_angle(MeshRef.rotation.y, atan2(Target.x,Target.z) , delta * nodelerpspeed)
	

func CalcGroundedRotationRate():
	
	if InputIsMoving == true:
		match Gait:
			Global.Gait.Walking:
				return lerp(CurrentMovementData.idle_Rotation_Rate,CurrentMovementData.Walk_Rotation_Rate, Global.MapRangeClamped(ActualVelocity.length(),0.0,CurrentMovementData.Walk_Speed,0.0,1.0)) * clamp(AimRate_H,1.0,3.0)
			Global.Gait.Running:
				return lerp(CurrentMovementData.Walk_Rotation_Rate,CurrentMovementData.Run_Rotation_Rate, Global.MapRangeClamped(ActualVelocity.length(),CurrentMovementData.Walk_Speed,CurrentMovementData.Run_Speed,1.0,2.0)) * clamp(AimRate_H,1.0,3.0)
			Global.Gait.Sprinting:
				return lerp(CurrentMovementData.Run_Rotation_Rate,CurrentMovementData.Sprint_Rotation_Rate,  Global.MapRangeClamped(ActualVelocity.length(),CurrentMovementData.Run_Speed,CurrentMovementData.Sprint_Speed,2.0,3.0)) * clamp(AimRate_H,1.0,2.5)
	else:
		return CurrentMovementData.idle_Rotation_Rate * clamp(AimRate_H,1.0,3.0)

var IsRotating = false :
	set(New):
		IsRotating = New
		if IsRotating:
			AnimRef.set("parameters/Turn/blend_amount" , 1)
		else:
			AnimRef.set("parameters/Turn/blend_amount" , 0)
	get: return IsRotating
func RotateInPlace(CameraAngle,MeshAngle):
	if abs(CameraAngle - MeshAngle) > 90:
		IsRotating = true
		var RotatingTween := create_tween()
		var NewRotation = MeshRef.rotation.y + deg2rad(90 if CameraAngle - MeshAngle > 0 else -90)
		AnimRef.set("parameters/RightOrLeft/blend_amount" ,0 if CameraAngle - MeshAngle > 0 else 1)
		if IsRotating:
			RotatingTween.tween_property(MeshRef,"rotation",Vector3(MeshRef.rotation.x,NewRotation,MeshRef.rotation.z),1.0667).set_ease(Tween.EASE_IN_OUT)
		RotatingTween.tween_callback(StopRotatingInPlace)
func StopRotatingInPlace():
	IsRotating = false

func IKLookAt(position: Vector3):
	if $LookAtObject:
		$LookAtObject.position = position


var PrevVelocity :Vector3
func AddMovementInput(direction: Vector3, Speed: float , Acceleration: float):
	if IsFlying == false:
		motion_velocity.x = lerp(motion_velocity.x, direction.x * Speed, Acceleration * get_physics_process_delta_time())
		motion_velocity.z = lerp(motion_velocity.z, direction.z * Speed, Acceleration * get_physics_process_delta_time())
	else:
		set_motion_velocity(get_motion_velocity().lerp(direction * Speed, Acceleration * get_physics_process_delta_time()))
		move_and_slide()
	InputVelocity = Speed * direction
	InputIsMoving = Speed > 0.0
	InputAcceleration = Acceleration * direction
	#
	ActualAcceleration = (motion_velocity - PrevVelocity) / (Acceleration * get_physics_process_delta_time())
	PrevVelocity = motion_velocity
	#
	#
	ActualVelocity = (get_real_velocity() * Vector3(1.0,0.0,1.0))
	#
	
	#TiltCharacterMesh
#	if Tilt == true:
#
#		tiltVector = (ActualAcceleration * direction).cross(Vector3.UP)
#		print(direction)
#		#MeshRef.rotation.x = lerp(MeshRef.rotation.x,tiltVector.x/5,Acceleration * get_physics_process_delta_time())
#		MeshRef.rotation.z = lerp(MeshRef.rotation.z,tiltVector.z/5,Acceleration * get_physics_process_delta_time())
	#



func MantleCheck():
	pass

func jump():
	vertical_velocity = Vector3.UP * jump_magnitude




#For Predicting Stop Location
func CalculateStopLocation(Velocity:Vector3,Acceleration:Vector3):
	#I didn't write the algorithm myself , you can find it here https://answers.unrealengine.com/questions/531204/predict-stop-position-of-character-ahead-in-time.html

	# Small number break loop when velocity is less than this value
	var SmallVelocity = 0.0

	# Current velocity at current frame in unit/frame
	var CurrentVelocityInFrame = Velocity * get_physics_process_delta_time()

	# Store velocity direction for later use
	var CurrentVelocityDirection = (Velocity*Vector3(1.0,0.0,1.0)).normalized() 

	# Current deacceleration at current frame in unit/frame^1.5
	var CurrentDeaccelerationInFrame = Acceleration.length() * pow(get_physics_process_delta_time(),1.5)

	# Calculate number of frames needed to reach zero velocity and gets its int value
	var StopFrameCount = CurrentVelocityInFrame.length() / CurrentDeaccelerationInFrame

	# float variable use to store distance to targeted stop location
	var StoppingDistance := 0.0

	#Do Stop calculation go through all frames and calculate stop distance in each frame and stack them
	
	for i in StopFrameCount:
		#Update velocity
		CurrentVelocityInFrame.lerp(Vector3.ZERO,CurrentDeaccelerationInFrame) 
		
		# Calculate distance travel in current frame and add to previous distance
		StoppingDistance += (CurrentVelocityInFrame*Vector3(1.0,0.0,1.0)).length() 
		
		#if velocity in XY plane is small break loop for safety
		if ((CurrentVelocityInFrame*Vector3(1.0,0.0,1.0)).length() <= SmallVelocity):
			break


	# return stopping distance from player position in previous frame

	
	#get_tree().get_root().get_node("Node/StopLocation").transform.origin = transform.origin + CurrentVelocityDirection * StoppingDistance + Vector3(0.0,0.75,0.0) #For Debug
	return transform.origin * get_physics_process_delta_time() + CurrentVelocityDirection * StoppingDistance


