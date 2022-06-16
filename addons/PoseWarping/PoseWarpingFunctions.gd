extends Node
class_name pose_warping
#For Predicting Stop Location
static func CalculateStopLocation(CurrentCharacterLocation:Vector3,Velocity:Vector3,deacceleration:Vector3,delta):
	return CurrentCharacterLocation + (Velocity * CalculateStopTime(Velocity,deacceleration) * delta * 8)

static func CalculateStopTime(Velocity:Vector3,deacceleration:Vector3):
	var time = Velocity.length() / deacceleration.length()
	return time


static func orientation_warping(CameraObject, Velocity:Vector3, CharacterRootNode, skeleton_ref, Hip = "Hips", Spines := ["Spine","Spine1","Spine2"], Offset := 0.0):
	var CameraAngle = Quaternion(Vector3(0,atan2(-CameraObject.transform.basis.z.z, -CameraObject.transform.basis.z.x),0)) 
	var VelocityAngle = Quaternion(Vector3(0,atan2(Velocity.z, Velocity.x),0)) 
	var IsMovingBackwardRelativeToCamera = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).z >= -0.1 else true
	var IsMovingLeftRelativeToCamera = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).x >= -0.1 else true
	var rotation_difference_camera_velocity = rad2deg(CameraAngle.angle_to(VelocityAngle))
	rotation_difference_camera_velocity = deg2rad(rotation_difference_camera_velocity)
	var hips_direction = rotation_difference_camera_velocity
	
	if IsMovingBackwardRelativeToCamera:
		# Make the legs face forward just like the forward walking
		hips_direction *= -1
		hips_direction = hips_direction + PI
	# Set Left or Right
	if IsMovingLeftRelativeToCamera:
		hips_direction *= -1
	if IsMovingBackwardRelativeToCamera:
		# since we rotated the legs to face forward the right and left will be reversed
		# so we need to reverse it back again after getting the right and left values
		hips_direction *= -1
	#Orient bones to face the forward direction
	set_bone_y_rotation(skeleton_ref,Hip,hips_direction,CharacterRootNode)
	for bone in Spines:
		set_bone_y_rotation(skeleton_ref,bone,-hips_direction/(Spines.size()+Offset),CharacterRootNode)
	
static func set_bone_y_rotation(skeleton,bone_name, y_rot,CharacterRootNode):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform = skeleton.get_bone_global_pose_no_override(bone)
	var rotate_amnt = y_rot - CharacterRootNode.global_transform.basis.get_euler().y
	bone_transform = bone_transform.rotated(Vector3(0,1,0), rotate_amnt)
	skeleton.set_bone_global_pose_override(bone, bone_transform,1.0,true)
	
