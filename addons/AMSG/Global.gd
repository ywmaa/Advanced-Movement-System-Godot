extends Node

#------------------ Player Enums ------------------#
enum gait {walking , running , sprinting}
enum movement_state {none , grounded , in_air , mantling, ragdoll}
enum movement_action {none ,low_mantle , high_mantle , rolling , getting_up}
enum overlay_state {default , rifle , pistol}
enum rotation_mode {velocity_direction , looking_direction , aiming}
enum stance {standing , crouching}
enum view_mode {third_person , first_person}
enum view_angle {right_shoulder , left_shoulder , head}
enum mantle_type {high_mantle , low_mantle, falling_catch}
enum movement_direction {forward , right, left, backward}


func map_range_clamped(value,InputMin,InputMax,OutputMin,OutputMax):
	value = clamp(value,InputMin,InputMax)
	return ((value - InputMin) / (InputMax - InputMin) * (OutputMax - OutputMin) + OutputMin)
