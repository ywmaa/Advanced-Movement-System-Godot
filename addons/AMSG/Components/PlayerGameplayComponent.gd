extends CharacterMovementComponent
class_name PlayerGameplayComponent


@export var networking : PlayerNetworkingComponent 
func _physics_process(delta):
	super._physics_process(delta)
#	Debug()
	if !networking.is_local_authority():
		if input_is_moving:
			if gait == Global.gait.sprinting:
				add_movement_input(input_direction, current_movement_data.sprint_speed,current_movement_data.sprint_acceleration)
			elif gait == Global.gait.running:
				add_movement_input(input_direction, current_movement_data.run_speed,current_movement_data.run_acceleration)
			else:
				add_movement_input(input_direction, current_movement_data.walk_speed,current_movement_data.walk_acceleration)
		else:
			add_movement_input(input_direction,0,deacceleration)
			
		return
	#------------------ Look At ------------------#
	match rotation_mode:
		Global.rotation_mode.velocity_direction:
			if input_is_moving:
				ik_look_at(actual_velocity + Vector3(0.0,1.0,0.0))
		Global.rotation_mode.looking_direction:
			ik_look_at(camera_root.SpringArm.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
		Global.rotation_mode.aiming:
			ik_look_at(camera_root.SpringArm.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
#func Debug():
#	$Status/Label.text = "InputSpeed : %s" % input_velocity.length()
#	$Status/Label2.text = "ActualSpeed : %s" % get_velocity().length()
