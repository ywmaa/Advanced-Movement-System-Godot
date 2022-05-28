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
	iw_blend = (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.walk_speed
	wr_blend = (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.run_speed * 2
	rs_blend = (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() / movement_script.current_movement_data.sprint_speed * 3
	
	if movement_script:
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
		match movement_script.stance:
			Global.stance.standing:
				set("parameters/VelocityDirection/crouch/current" ,0)
			Global.stance.crouching:
				set("parameters/VelocityDirection/crouch/current" ,1)
				iw_blend = iw_blend/2
				wr_blend = wr_blend/2
				rs_blend = rs_blend/2
		
		
		if movement_script.rotation_mode == Global.rotation_mode.velocity_direction:
			set("parameters/VelocityOrLooking/blend_amount" ,0)
			## Currently using imediate switch because there is a bug in the animation blend
			
			
			#Blend
			if movement_script.input_is_moving:
				if  movement_script.gait == Global.gait.sprinting:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , rs_blend)
					set("parameters/VelocityDirection/IWR_Blend_Crouch/blend_position" , rs_blend)
				elif movement_script.gait == Global.gait.running:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , wr_blend)
					set("parameters/VelocityDirection/IWR_Blend_Crouch/blend_position" , wr_blend)
				elif movement_script.gait == Global.gait.walking:
					set("parameters/VelocityDirection/IWR_Blend/blend_position" , iw_blend)
					set("parameters/VelocityDirection/IWR_Blend_Crouch/blend_position" , iw_blend)
			else:
				set("parameters/VelocityDirection/IWR_Blend/blend_position" , 0)
				set("parameters/VelocityDirection/IWR_Blend_Crouch/blend_position" , 0)
		else: #Animation blend for Both looking direction mode and aiming mode
			set("parameters/VelocityOrLooking/blend_amount" ,1)
			
			
			#Direction
			var MovementDirectionRelativeToCamera = movement_script.get_velocity().normalized().rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y)
			MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera.x * -MovementDirectionRelativeToCamera.z if abs(MovementDirectionRelativeToCamera.z) > 0.1 else MovementDirectionRelativeToCamera.x #I tried comparing with 0.0 but because of me using a physically calc velocity it will most of the time give value bigger than 0.0 so compare with 0.1 instead
			var IsMovingBackwardRelativeToCamera = false if -movement_script.get_velocity().rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y).z >= -0.1 else true
			if IsMovingBackwardRelativeToCamera:
				MovementDirectionRelativeToCamera = MovementDirectionRelativeToCamera * -1
			
			
			#Blend
			if movement_script.input_velocity.length() > 0.0:
				if (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.walk_speed and movement_script.gait == Global.gait.walking: 
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" , Vector2(MovementDirectionRelativeToCamera,-iw_blend if IsMovingBackwardRelativeToCamera else iw_blend))
				elif (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.run_speed and movement_script.gait == Global.gait.running:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(MovementDirectionRelativeToCamera,-wr_blend if IsMovingBackwardRelativeToCamera else wr_blend))
				elif (movement_script.get_velocity() * Vector3(1.0,0.0,1.0)).length() <= movement_script.current_movement_data.sprint_speed and movement_script.gait == Global.gait.sprinting:
					set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,rs_blend))
			else:
				set("parameters/LookingDirection/LookingDirectionBlend/blend_position" ,  Vector2(0,0))
		
		
		#On Stopped
		if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):
			var seek_time = get_node(anim_player).get_animation(tree_root.get_node("VelocityDirection").get_node("StopAnim").animation).length - distance_matching.CalculateStopTime((movement_script.get_velocity() * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.direction)
			print(distance_matching.CalculateStopTime((movement_script.get_velocity() * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.direction))

			set("parameters/VelocityDirection/StopSeek/seek_position",seek_time)
			set("parameters/VelocityDirection/Stop/active",1)
			

		#Rotate In Place
		set("parameters/Turn/blend_amount" , 1 if movement_script.is_rotating_in_place else 0)
		set("parameters/RightOrLeft/blend_amount" ,0 if movement_script.rotation_difference_camera_mesh > 0 else 1)




