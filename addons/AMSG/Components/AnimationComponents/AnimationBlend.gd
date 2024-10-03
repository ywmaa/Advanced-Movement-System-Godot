extends AnimationTree
class_name AnimBlend
@onready @export var movement_script : CharacterMovementComponent  # I use this to get variables from main movement script

func _physics_process(_delta):
	if !movement_script:
		return

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

	#standing
	if !movement_script.input_is_moving:
		set("parameters/VelocityDirection/Standing/transition_request","Idle")
		set("parameters/VelocityDirection/crouching/transition_request","Idle")
	if movement_script.gait == Global.gait.walking and movement_script.input_is_moving:
		set("parameters/VelocityDirection/Standing/transition_request","Walk")
		set("parameters/VelocityDirection/crouching/transition_request","Walk")
	if movement_script.gait == Global.gait.running and movement_script.input_is_moving:
		set("parameters/VelocityDirection/Standing/transition_request","Jog")
	if movement_script.gait == Global.gait.sprinting and movement_script.input_is_moving:
		set("parameters/VelocityDirection/Standing/transition_request","Run")

	#Couch/stand switch
	match movement_script.stance: 
		Global.stance.standing:
			set("parameters/VelocityDirection/crouch/transition_request" , "stand")
		Global.stance.crouching:

			set("parameters/VelocityDirection/crouch/transition_request" , "crouch")


	if movement_script.rotation_mode == Global.rotation_mode.looking_direction or movement_script.rotation_mode == Global.rotation_mode.aiming:
		if movement_script.animation_is_moving_backward_relative_to_camera == false:
			set("parameters/VelocityDirection/WalkFB/transition_request","Forward")
			set("parameters/VelocityDirection/JogFB/transition_request","Forward")
		else:
			set("parameters/VelocityDirection/WalkFB/transition_request","Backward")
			set("parameters/VelocityDirection/JogFB/transition_request","Backward")
			
	else:
		set("parameters/VelocityDirection/WalkFB/transition_request","Forward")
		set("parameters/VelocityDirection/JogFB/transition_request","Forward")

	#On Stopped
	if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):
		movement_script.pose_warping.CalculateStopLocation(movement_script.deacceleration)
		var seek_time = 0.0#get_node(anim_player).get_animation(tree_root.get_node("VelocityDirection").get_node("StopAnim").animation).length - movement_script.pose_warping_instance.CalculateStopTime((movement_script.actual_velocity * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.input_direction)
		set("parameters/VelocityDirection/StopSeek/seek_position",seek_time)
	if !movement_script.input_is_moving:
		set("parameters/VelocityDirection/Standing/transition_request","Stop")
	#Rotate In Place
	set("parameters/Turn/blend_amount" , 1 if movement_script.is_rotating_in_place else 0)
	set("parameters/RightOrLeft/blend_amount" ,0 if movement_script.rotation_difference_camera_mesh > 0 else 1)
