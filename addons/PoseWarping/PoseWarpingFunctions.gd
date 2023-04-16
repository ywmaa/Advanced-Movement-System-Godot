extends Node
class_name pose_warping
## For Predicting Stop Location
## it uses a linear equation : d = v*t + 0.5 * a * t^2
## v is velocity. t is time. a is acceleration
func CalculateStopLocation(CurrentCharacterLocation:Vector3,Velocity:Vector3,deacceleration:Vector3,delta):
	var time = CalculateStopTime(Velocity,deacceleration)
	return CurrentCharacterLocation + (Velocity * time + 0.5*deacceleration*pow(time,2))

func CalculateStopTime(Velocity:Vector3,deacceleration:Vector3):
	var time = Velocity.length() / deacceleration.length()
	return time


var previous_direction : float
var orientation_direction : float
var cleared_override : bool = true
func orientation_warping(enabled:bool,CameraObject, Velocity:Vector3, skeleton_ref:Skeleton3D, Hip :String= "Hips", Spines :Array[String]= ["Spine","Spine1","Spine2"], Offset := 0.0, delta :float= 1.0, turn_rate :float= 10.0):
	
	if !enabled and !cleared_override:
		set_bone_y_rotation(skeleton_ref,Hip,0,false)
		for bone in Spines:
			set_bone_y_rotation(skeleton_ref,bone,0,false)
		cleared_override = true
	if is_equal_approx(Velocity.length(),0.0) or !enabled:
		return
	cleared_override = false
	var CameraAngle :Quaternion = Quaternion(Vector3(0,1,0),atan2(-CameraObject.transform.basis.z.z, -CameraObject.transform.basis.z.x)) 
	var VelocityAngle :Quaternion = Quaternion(Vector3(0,1,0),atan2(Velocity.z, Velocity.x)) 
	var IsMovingBackwardRelativeToCamera :bool = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).z >= -0.1 else true
	var IsMovingLeftRelativeToCamera :bool = false if -Velocity.rotated(Vector3.UP,-CameraObject.transform.basis.get_euler().y).x >= -0.1 else true
	var rotation_difference_camera_velocity :float = CameraAngle.angle_to(VelocityAngle)
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
		set_bone_y_rotation(skeleton_ref,bone,(-orientation_direction/(Spines.size()))+Offset)
		
	
func set_bone_y_rotation(skeleton:Skeleton3D,bone_name:String, y_rot:float, presistant:bool=true):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose_no_override(bone)
	bone_transform = bone_transform.rotated(Vector3(0,1,0), y_rot)
	
	skeleton.set_bone_global_pose_override(bone, bone_transform,1.0,presistant)
	
	
