extends CharacterBody3D




#####################################
#Refrences
@onready var AnimRef = $AnimationTree
#####################################







#####################################
#Movement Settings
@export var acceleration = 15
@export var angular_acceleration = 7
var weight_on_ground = 4
@export var gravity = 28


@export var roll_magnitude = 17
@export var jump_magnitude = 8.4

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

var direction = Vector3.FORWARD
var movement_speed = 0
var vertical_velocity = 0
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO
var aim_turn = 0

var CurrentMovementData = {
	Walk_Speed = 1.75, 
	Run_Speed = 3.75, 
	Sprint_Speed = 6.5,
	Movement_Curve = preload("res://FakeCurve.tres"), 
	Rotation_Rate_Curve = preload("res://FakeCurve.tres"), 
}



#status
var MovementState = GlobalEnums.MovementState
var PrevMovementState = GlobalEnums.MovementState
var MovementAction = GlobalEnums.MovementAction
var RotationMode = GlobalEnums.RotationMode
var Gait = GlobalEnums.Gait
var Stance = GlobalEnums.Stance
var OverlayState = GlobalEnums.OverlayState
var sprinting = false

#####################################


func _ready():
	CurrentMovementData = MovementData.Normal.LookingDirection.Standing
	
	
	
	
	
func _input(event):
	if event is InputEventMouseMotion: 
		aim_turn = -event.relative.x * 0.015
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if event.is_action_pressed("sprint"):
			sprinting = false if sprinting else true 
	else:
		sprinting = Input.is_action_pressed("sprint")
		
	
	if is_on_floor():
		if !$AnimationTree.get("parameters/roll/active"):
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
	#------------------ roll control ------------------#
	if !$roll_timer.is_stopped():
		acceleration = 3.5
	else:
		acceleration = 5.0
	#------------------ Aim ------------------#
	if Input.is_action_pressed("aim"):
		if !$AnimationTree.get("parameters/roll/active"):
			$AnimationTree.set("parameters/aim_transition/current",0)
	else:
		$AnimationTree.set("parameters/aim_transition/current",1)
	
	#------------------ Movement ------------------#
	
	
	var h_rot = $CameraRoot/h.transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
				0,
				Input.get_action_strength("forward") - Input.get_action_strength("back"))
		strafe_dir = direction
		direction = direction.rotated(Vector3.UP,h_rot).normalized()
		if sprinting && $AnimationTree.get("parameters/aim_transition/current") == 1 :
			movement_speed = CurrentMovementData.Run_Speed
		else:
			movement_speed = CurrentMovementData.Walk_Speed
			
	else:
		movement_speed = 0
		strafe_dir = Vector3.ZERO
		if $AnimationTree.get("parameters/aim_transition/current") == 0:
			direction = $CameraRoot/h.transform.basis.z
			
	#Move
	linear_velocity.x = lerp(linear_velocity.x, direction.x * movement_speed ,delta * acceleration) 
	linear_velocity.y = lerp(linear_velocity.y, vertical_velocity - get_floor_normal().y * weight_on_ground ,delta * acceleration) 
	linear_velocity.z = lerp(linear_velocity.z, direction.z * movement_speed,delta * acceleration) 
	move_and_slide()
	


		
	
	
	
	#------------------ Gravity ------------------#
	if !is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		if vertical_velocity < -20:
			roll()
		vertical_velocity = 0
		
	#------------------ Rotate Character Mesh ------------------#
	if $AnimationTree.get("parameters/aim_transition/current") == 1:
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, atan2(direction.x , direction.z), delta * angular_acceleration)
	else:
		$Armature.rotation.y = lerp_angle($Armature.rotation.y, h_rot, delta * angular_acceleration)
		
		
	strafe.x = lerp(strafe.x,strafe_dir.x ,delta * acceleration)
	strafe.y = lerp(strafe.y,strafe_dir.y,delta * acceleration)
	strafe.z = lerp(strafe.z,strafe_dir.z + aim_turn,delta * acceleration)
	
	$AnimationTree.set("parameters/strafe/blend_position",Vector2(-strafe.x,strafe.z))
	
	#------------------ blend the animation with the velocity ------------------#
	#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
	var iw_blend = (linear_velocity.length() - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
	var wr_blend = (linear_velocity.length() - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
	
	if linear_velocity.length() <= CurrentMovementData.Walk_Speed:
		$AnimationTree.set("parameters/IWR_blend/blend_amount" , iw_blend)
	else:
		$AnimationTree.set("parameters/IWR_blend/blend_amount" , wr_blend)
		
	
	
	#------------------ Reset Values ------------------#
	aim_turn = 0
	#------------------ Debugging ------------------#
#	$Status/Label.text = "direction : %s" % direction
#	$Status/Label2.text = "velocity : %s" % linear_velocity



func roll():
	$AnimationTree.set("parameters/roll/active",true)
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










