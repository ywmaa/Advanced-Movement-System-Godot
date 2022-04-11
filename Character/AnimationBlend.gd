extends AnimationTree
class_name AnimBlend
@export var skeleton_path : NodePath
@onready var movement_script : CharacterMovement = get_parent().get_parent() # I use this to get variables from main movement script
@onready var camera_root : CameraRoot = movement_script.get_node("CameraRoot")
@onready var skeleton_ref : Skeleton3D = get_node(skeleton_path)



var iw_blend :float
var wr_blend :float
var rs_blend :float
func _physics_process(delta):
#	#------------------ blend the animation with the velocity ------------------#
	
	#Blend Animations with Movement4
	#Speed
	iw_blend = (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.walk_speed
	wr_blend = (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.run_speed * 2
	rs_blend = (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.sprint_speed * 3
	
	if movement_script:
		if movement_script.rotation_mode == Global.rotation_mode.velocity_direction:
			set("parameters/VelocityOrLooking/blend_amount" ,0)
			## Currently using imediate switch because there is a bug in the animation blend
			
			
			#Blend
			if movement_script.input_is_moving:
				if  movement_script.gait == Global.gait.sprinting:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , rs_blend)
				elif movement_script.gait == Global.gait.running:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , wr_blend)
				elif movement_script.gait == Global.gait.walking:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , iw_blend)
			else:
				set("parameters/VelocityDirection/IWR_Blend/blend_position" , 0)
		else: #Animation blend for Both looking direction mode and aiming mode
			set("parameters/VelocityOrLooking/blend_amount" ,1)
			
			
			#Direction
			var MovementDirectionRelativeToCamera = movement_script.get_real_velocity().normalized().rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y)
			MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera.x * -MovementDirectionRelativeToCamera.z if abs(MovementDirectionRelativeToCamera.z) > 0.1 else MovementDirectionRelativeToCamera.x #I tried comparing with 0.0 but because of me using a physically calc velocity it will most of the time give value bigger than 0.0 so compare with 0.1 instead
			var IsMovingBackwardRelativeToCamera = false if -movement_script.get_real_velocity().rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y).z >= -0.1 else true
			if IsMovingBackwardRelativeToCamera:
				MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera * -1
			
			
			#Blend
			if movement_script.input_velocity.length() > 0.0:
				if (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.walk_speed and movement_script.gait == Global.gait.walking: 
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" , Vector2(MovementDirectionRelativeToCamera,-iw_blend if IsMovingBackwardRelativeToCamera else iw_blend))
				elif (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.run_speed and movement_script.gait == Global.gait.running:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(MovementDirectionRelativeToCamera,-wr_blend if IsMovingBackwardRelativeToCamera else wr_blend))
				elif (movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.sprint_speed and movement_script.gait == Global.gait.sprinting:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,rs_blend))
			else:
				set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,0))
		
		
		#Set Animation State
		match movement_script.movement_state:
			Global.movement_state.none:
				pass
			Global.movement_state.grounded:
				set("parameters/InAir/blend_amount" , 0)
			Global.movement_state.in_air:
				set("parameters/InAir/blend_amount" , 1)
			Global.movement_state.mantling:
				pass
			Global.movement_state.ragdoll:
				pass
				
		
		
		#On Stopped
		if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):
			distance_matching.CalculateStopLocation(movement_script.transform.origin,(movement_script.get_real_velocity() * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.direction,get_physics_process_delta_time())





