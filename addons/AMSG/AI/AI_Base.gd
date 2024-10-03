extends CharacterMovementComponent
class_name AI


var h_rotation :float
var v_rotation :float

var direction := Vector3.FORWARD

var Previousrotation_mode 
func _ready():
	super._ready()
	
	
func _physics_process(delta):
	super._physics_process(delta)
	
	
	#------------------ Input Movement ------------------#
	h_rotation = $CameraRoot.HObject.transform.basis.get_euler().y
	v_rotation = $CameraRoot.VObject.transform.basis.get_euler().x

	
	add_movement_input(Vector3(0.0,0.0,1.0), current_movement_data.walk_speed,current_movement_data.walk_acceleration)
	
	#------------------ Look At ------------------#
	match rotation_mode:
		Global.rotation_mode.velocity_direction:
			if input_is_moving:
				ik_look_at(actual_velocity + Vector3(0.0,1.0,0.0))
		Global.rotation_mode.looking_direction:
			ik_look_at(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
		Global.rotation_mode.aiming:
			ik_look_at(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
