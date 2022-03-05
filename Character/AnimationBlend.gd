extends AnimationTree

@onready var movement_script = get_node("..") # I use this to get variables from main movement script
@onready var CameraRoot = get_node("../CameraRoot")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	#------------------ blend the animation with the velocity ------------------#

	#Blend Animations with Movement
	if movement_script:
		if movement_script.RotationMode == Global.RotationMode.VelocityDirection:
			set("parameters/VelocityOrLooking/blend_amount" ,0)
			## Currently using imediate switch because there is a bug in the animation blend
			
			#Speed
			#https://www.desmos.com/calculator/wnajovy5pc Explains the linear equations here to blend the animation with the velocity
	#		var iw_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / CurrentMovementData.Walk_Speed
	#		var wr_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
	#		var rs_blend = (ActualVelocity.length() - CurrentMovementData.Walk_Speed) / (CurrentMovementData.Sprint_Speed - CurrentMovementData.Run_Speed)
			
			#Blend
			if movement_script.InputVelocity.length() > 0.0:
				if movement_script.Gait == Global.Gait.Sprinting :
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , 2)
				elif movement_script.Gait == Global.Gait.Running:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , 1)
				else:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , 0)
			else:
				set("parameters/VelocityDirection/IWR_Blend/blend_position" , -1)
		else: #Animation blend for Both looking direction mode and aiming mode
			set("parameters/VelocityOrLooking/blend_amount" ,1)
			
			#Speed
	#		var iw_blend = ActualVelocity.length() / CurrentMovementData.Walk_Speed
	#		var wr_blend = ActualVelocity.length() / (CurrentMovementData.Run_Speed - CurrentMovementData.Walk_Speed)
	#		var rs_blend = ActualVelocity.length() / (CurrentMovementData.Sprint_Speed - CurrentMovementData.Run_Speed)
			
			#Direction
			var MovementDirectionRelativeToCamera = movement_script.get_real_velocity().normalized().rotated(Vector3.UP,-CameraRoot.HObject.transform.basis.get_euler().y)
			MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera.x * -MovementDirectionRelativeToCamera.z if abs(MovementDirectionRelativeToCamera.z) > 0.1 else MovementDirectionRelativeToCamera.x #I tried comparing with 0.0 but because of me using a physically calc velocity it will most of the time give value bigger than 0.0 so compare with 0.1 instead
			var IsMovingBackwardRelativeToCamera = false if -movement_script.get_real_velocity().rotated(Vector3.UP,-CameraRoot.HObject.transform.basis.get_euler().y).z >= -0.1 else true
			if IsMovingBackwardRelativeToCamera:
				MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera * -1
			
			
			#Blend
			if movement_script.InputVelocity.length() > 0.0:
				if movement_script.ActualVelocity.length() <= movement_script.CurrentMovementData.Walk_Speed :
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" , Vector2(MovementDirectionRelativeToCamera,-1 if IsMovingBackwardRelativeToCamera else 1))
				elif movement_script.ActualVelocity.length() <= movement_script.CurrentMovementData.Run_Speed:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(MovementDirectionRelativeToCamera,-2 if IsMovingBackwardRelativeToCamera else 2))
				elif movement_script.ActualVelocity.length() <= movement_script.CurrentMovementData.Sprint_Speed:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,3))
			else:
				set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,0))
		
		
		#Set Animation State
		match movement_script.MovementState:
			Global.MovementState.None:
				pass
			Global.MovementState.Grounded:
				set("parameters/InAir/blend_amount" , 0)
			Global.MovementState.In_Air:
				set("parameters/InAir/blend_amount" , 1)
			Global.MovementState.Mantling:
				pass
			Global.MovementState.Ragdoll:
				pass
				
		
		
		#On Stopped
		if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):
			distance_matching.CalculateStopLocation(movement_script.transform.origin,movement_script.ActualVelocity,movement_script.Deacceleration * movement_script.direction,get_physics_process_delta_time())





