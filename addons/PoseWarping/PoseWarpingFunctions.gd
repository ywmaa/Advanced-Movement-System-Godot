extends Node
class_name pose_warping
#For Predicting Stop Location
func CalculateStopLocation(CurrentCharacterLocation:Vector3,Velocity:Vector3,deacceleration:Vector3,delta):
	return CurrentCharacterLocation + (Velocity * CalculateStopTime(Velocity,deacceleration) * delta * 8)

func CalculateStopTime(Velocity:Vector3,deacceleration:Vector3):
	var time = Velocity.length() / deacceleration.length()
	return time


var previous_direction : float
var orientation_direction : float
func orientation_warping(enabled:bool,CameraObject, Velocity:Vector3, skeleton_ref, Hip = "Hips", Spines := ["Spine","Spine1","Spine2"], Offset := 0.0, delta = 1.0, turn_rate = 10.0):
	
	skeleton_ref.clear_bones_global_pose_override()
	if is_equal_approx(Velocity.length(),0.0) or !enabled:
		return
	var CameraAngle = Quaternion(Vector3(0,1,0),atan2(-CameraObject.transform.basis.z.z, -CameraObject.transform.basis.z.x)) 
	var VelocityAngle = Quaternion(Vector3(0,1,0),atan2(Velocity.z, Velocity.x)) 
	var IsMovingBackwardRelativeToCamera = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).z >= -0.1 else true
	var IsMovingLeftRelativeToCamera = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).x >= -0.1 else true
	var rotation_difference_camera_velocity = CameraAngle.angle_to(VelocityAngle)
	previous_direction = orientation_direction
	orientation_direction = rotation_difference_camera_velocity
	if IsMovingBackwardRelativeToCamera:
		# Make the legs face forward just like the forward walking
		orientation_direction *= -1
		orientation_direction = orientation_direction + PI
		
		
	# Set Left or Right
	if IsMovingLeftRelativeToCamera:
		orientation_direction *= -1

	if IsMovingBackwardRelativeToCamera:
		# since we rotated the legs to face forward, then the right and left will be reversed
		# so we need to reverse it back again after getting the right and left values
		orientation_direction *= -1
	
	orientation_direction = clampf(lerp_angle(previous_direction,orientation_direction,delta*turn_rate),-PI/2, PI/2)
	#Orient bones to face the forward direction
	set_bone_y_rotation(skeleton_ref,Hip,orientation_direction)
	for bone in Spines:
		set_bone_y_rotation(skeleton_ref,bone,-orientation_direction/(Spines.size()+Offset))
	
func set_bone_y_rotation(skeleton,bone_name, y_rot):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose_no_override(bone)
	var rotate_amount = y_rot 
	bone_transform = bone_transform.rotated(Vector3(0,1,0), rotate_amount)
	skeleton.set_bone_global_pose_override(bone, bone_transform,1.0,true)
	
	
