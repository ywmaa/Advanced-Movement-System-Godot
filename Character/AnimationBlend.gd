extends AnimationTree
class_name AnimBlend
@onready var movement_script := get_parent() # I use this to get variables from main movement script
#@onready var camera_root : CameraRoot = movement_script.get_node("CameraRoot")

func _physics_process(delta):
	
	
#	#------------------ blend the animation with the velocity ------------------#

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
		#Couch/stand switch
		match movement_script.stance: 
			Global.stance.standing:
				set("parameters/VelocityDirection/crouch/current" ,0)
			Global.stance.crouching:
				set("parameters/VelocityDirection/crouch/current" ,1)
		
		#standing
		set("parameters/VelocityOrLooking/blend_amount" ,0)
		set("parameters/VelocityDirection/StateMachine/conditions/idle",!movement_script.input_is_moving)
		set("parameters/VelocityDirection/StateMachine/conditions/walking",movement_script.gait == Global.gait.walking and movement_script.input_is_moving)
		set("parameters/VelocityDirection/StateMachine/conditions/running",movement_script.gait == Global.gait.running and movement_script.input_is_moving)
		set("parameters/VelocityDirection/StateMachine/conditions/sprinting",movement_script.gait == Global.gait.sprinting and movement_script.input_is_moving)
		

		if movement_script.rotation_mode == Global.rotation_mode.looking_direction or movement_script.rotation_mode == Global.rotation_mode.aiming:
			if movement_script.IsMovingBackwardRelativeToCamera == false:
				set("parameters/VelocityDirection/StateMachine/Walk/FB/current",0)
				set("parameters/VelocityDirection/StateMachine/Jog/FB/current",0)
			else:
				set("parameters/VelocityDirection/StateMachine/Walk/FB/current",1)
				set("parameters/VelocityDirection/StateMachine/Jog/FB/current",1)
		else:
			set("parameters/VelocityDirection/StateMachine/Walk/FB/current",0)
			set("parameters/VelocityDirection/StateMachine/Jog/FB/current",0)
		# Crouching
		set("parameters/VelocityDirection/StateMachine 2/conditions/idle",!movement_script.input_is_moving)
		set("parameters/VelocityDirection/StateMachine 2/conditions/walking",movement_script.gait == Global.gait.walking and movement_script.input_is_moving)
		#On Stopped
		if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):
			
			var seek_time = get_node(anim_player).get_animation(tree_root.get_node("VelocityDirection").get_node("StateMachine").get_node("Stopping").get_node("StopAnim").animation).length - pose_warping.CalculateStopTime((movement_script.get_velocity() * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.direction)
			set("parameters/VelocityDirection/StateMachine/Stopping/StopSeek/seek_position",seek_time)
		set("parameters/VelocityDirection/StateMachine/conditions/stop",!movement_script.input_is_moving)
		
		#Rotate In Place
		set("parameters/Turn/blend_amount" , 1 if movement_script.is_rotating_in_place else 0)
		set("parameters/RightOrLeft/blend_amount" ,0 if movement_script.rotation_difference_camera_mesh > 0 else 1)




