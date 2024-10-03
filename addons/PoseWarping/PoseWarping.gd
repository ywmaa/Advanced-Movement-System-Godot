@tool
extends SkeletonModifier3D
class_name PoseWarping
## a Node that Handles Pose Warping for character for enhanced animations
## Must be a child of Skeleton3D

@export var debug : bool = false

## Character Node, either CharacterBody3D or RigidBody3D
@export var character_node : PhysicsBody3D
## The Character Skeleton that is going to be modified
@onready var character_skeleton : Skeleton3D = get_skeleton()
## SkeletonIK3D Node that adjusts the left leg IK
@export var LeftLegIK : SkeletonIK3D
## SkeletonIK3D Node that adjusts the right leg IK
@export var RightLegIK : SkeletonIK3D
## Hips bone name, Please Write the correct hips bone name according to your skeleton.
@export_enum(" ") var hips_bone_name : String = "Hips"
@export_enum(" ") var left_knee_bone_name : String = "LeftLeg"
@export_enum(" ") var right_knee_bone_name : String = "RightLeg"
#@export_enum(" ") var left_leg_root_bone_name : String = "LeftUpLeg"
#@export_enum(" ") var left_leg_tip_bone_name : String = "LeftFoot"
#@export_enum(" ") var right_leg_root_bone_name : String = "RightUpLeg"
#@export_enum(" ") var right_leg_tip_bone_name : String = "RightFoot"
## Character Info
var character_velocity : Vector3
var character_prev_velocity : Vector3
var character_acceleration : Vector3
var character_prev_acceleration : Vector3
var character_position : Vector3
var character_prev_position : Vector3


@onready var LeftLegIKTarget : Marker3D = $LeftTargetRotation/LeftIKTarget
@onready var RightLegIKTarget : Marker3D = $RightTargetRotation/RightIKTarget

@export_subgroup("Orientation Warping", "orientation_warping_")
## Orientation Warping is a system that adjusts the character's Legs and Hips (Lower body)
## To adapt to character movement direction.
@export var orientation_warping_enable : bool
## This is the object that contains the camera horizontal rotation
## it could be the camera object itself.
@export var orientation_warping_camera_h_object : Node3D
## Spine Bones Names, Please Write the correct bone names for all of the spine bones according to your skeleton.
@export_enum(" ") var orientation_warping_spine_bones_names : Array[String] = ["Spine","Spine1","Spine2"] 
## An offset added to the Spine Bones rotation relative to camera forward
@export var orientation_warping_offset := 0.0 
## 
@export var orientation_warping_turn_rate :float= 1.5


@export_subgroup("Stride - Speed Warping", "stride_warping_")
## Stride Warping is a system that adjusts the character's Leg using the SkeletonIK3D node
## To adapt to the character movement speed, to achieve more realistic look and less foot sliding.
@export var stride_warping_enable : bool = true

@export_subgroup("Slope Warping - Leg on ground IK", "slope_warping_")
## Slope Warping is a system that adjusts the character's Leg using the SkeletonIK3D node
## To adapt to the ground shape, like hills, and uneven ground, etc.
@export var slope_warping_enable : bool = true
## Locks the foot to the ground to prevent feet sliding.
@export var slope_warping_feet_locking_enable : bool = true
## Foot Raycast Length (The Raycast responsible to detect if foot on ground and should be locked or not)
@export var slope_warping_foot_ground_touch_raycast_length : float = 0.14
@onready var slope_warping_raycast_left_touch_detection : RayCast3D = $LeftFootAttachment/LeftLegTouchRayCast
@onready var slope_warping_raycast_left : RayCast3D = $LeftLegTargetRayCast
@onready var slope_warping_bone_attachment_left_foot : BoneAttachment3D = $LeftFootAttachment
@onready var slope_warping_raycast_right_touch_detection : RayCast3D = $RightFootAttachment/RightLegTouchRayCast
@onready var slope_warping_raycast_right : RayCast3D = $RightLegTargetRayCast
@onready var slope_warping_bone_attachment_right_foot : BoneAttachment3D = $RightFootAttachment
@export var slope_warping_foot_height_offset : float = 0.015


@onready var left_target_rotation = $LeftTargetRotation
@onready var right_target_rotation = $RightTargetRotation
@onready var left_leg_ground_normal_ray_cast = $LeftFootAttachment/LeftLegGroundNormalRayCast
@onready var right_leg_ground_normal_ray_cast = $RightFootAttachment/RightLegGroundNormalRayCast
@onready var on_floor_ray_cast: RayCast3D = $OnFloorRayCast
var is_on_floor: bool = false

func _validate_property(property: Dictionary) -> void:
	if property.name == "hips_bone_name" or property.name == "orientation_warping_spine_bones_names"\
		or property.name == "right_knee_bone_name" or property.name == "left_knee_bone_name"\
		or property.name == "left_leg_root_bone_name" or property.name == "left_leg_tip_bone_name"\
		or property.name == "right_leg_root_bone_name" or property.name == "right_leg_tip_bone_name":
		if character_skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = character_skeleton.get_concatenated_bone_names()

func _ready():
	if !LeftLegIK:
		assert(false, "Left Leg IK Must be SkeletonIK3D.")
	if !RightLegIK:
		assert(false, "Right Leg IK Must be SkeletonIK3D.")
	if not get_parent() is Skeleton3D:
		assert(false, "Parent Must be Skeleton3D.")
		update_configuration_warnings()
	if not character_node is CharacterBody3D and not character_node is RigidBody3D:
		assert(false, "Character Node Must be either CharacterBody3D or RigidBody3D, please choose the right node from the inspector.")
	#slope_warping_bone_attachment_left_foot.set_external_skeleton(character_skeleton.get_path())
	slope_warping_bone_attachment_left_foot.bone_name = String(LeftLegIK.tip_bone)
	#slope_warping_bone_attachment_right_foot.set_external_skeleton(character_skeleton.get_path())
	slope_warping_bone_attachment_right_foot.bone_name = String(RightLegIK.tip_bone)
	
	slope_warping_raycast_left_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length
	slope_warping_raycast_right_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length

	slope_warping_raycast_left.add_exception(character_node)
	slope_warping_raycast_right.add_exception(character_node)
	slope_warping_raycast_left_touch_detection.add_exception(character_node)
	slope_warping_raycast_right_touch_detection.add_exception(character_node)
	on_floor_ray_cast.add_exception(character_node)
	
	LeftLegIK.target_node = LeftLegIKTarget.get_path()
	RightLegIK.target_node = RightLegIKTarget.get_path()


@onready var result_debug = $LeftTargetRotation/LeftIKTarget/ResultDebug
@onready var result_debug2 = $RightTargetRotation/RightIKTarget/ResultDebug

func calculate_character_info():
	character_prev_position = character_position
	character_prev_velocity = character_velocity
	character_prev_acceleration = character_acceleration
	
	
	character_position = character_skeleton.global_position
	# Distance/Time = Velocity
	character_velocity = (character_position - character_prev_position) / get_physics_process_delta_time()
	# Delta Velocity / Delta Time = Acceleration
	character_acceleration = (character_velocity - character_prev_velocity) / get_physics_process_delta_time()

	if debug:
		DebugDraw3D.draw_arrow(character_position, character_position+character_velocity, Color.ORANGE, 0.1, false, 0)

func _physics_process(delta: float) -> void:
	if !LeftLegIK or !RightLegIK:
		return
	calculate_character_info()
	is_on_floor = on_floor_ray_cast.is_colliding()

func _process_modification():
	if !LeftLegIK or !RightLegIK:
		return
	#DebugDraw3D.draw_sphere(slope_warping_bone_attachment_left_foot.global_position, 0.1, Color.RED, 0.0)
	#DebugDraw3D.draw_sphere(slope_warping_bone_attachment_right_foot.global_position, 0.1, Color.RED, 0.0)
	#if Engine.is_editor_hint():
		#return
	#global_transform.basis = foot_look_at_y(Vector3.ZERO, character_skeleton.global_transform.basis.z, left_leg_ground_normal_ray_cast.get_collision_normal())
	
	#RightLegIK.magnet = right_magnet.position.rotated(Vector3.UP, orientation_direction)
	#LeftLegIK.magnet = left_magnet.position.rotated(Vector3.UP, orientation_direction)
	if (stride_warping_enable or slope_warping_enable) and is_on_floor:
		var bone_transform_left = character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(LeftLegIK.tip_bone)))
		var bone_transform_right = character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(RightLegIK.tip_bone)))
		slope_warping_bone_attachment_left_foot.transform = bone_transform_left
		slope_warping_bone_attachment_right_foot.transform = bone_transform_right
		LeftLegIKTarget.transform.origin = lerp(LeftLegIKTarget.transform.origin, bone_transform_left.origin, get_physics_process_delta_time()*2)
		LeftLegIKTarget.transform.basis = lerp(LeftLegIKTarget.transform.basis, bone_transform_left.basis, get_physics_process_delta_time()*2)
		RightLegIKTarget.transform.origin = lerp(RightLegIKTarget.transform.origin, bone_transform_right.origin, get_physics_process_delta_time()*2)
		RightLegIKTarget.transform.basis = lerp(RightLegIKTarget.transform.basis, bone_transform_right.basis, get_physics_process_delta_time()*2)
		if !LeftLegIK.is_running():
			LeftLegIK.start()
		if !RightLegIK.is_running():
			RightLegIK.start()
	else:
		if LeftLegIK.is_running():
			LeftLegIK.stop()
		if RightLegIK.is_running():
			RightLegIK.stop()

	var left_foot_position : Vector3 = (character_skeleton.global_transform * character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(LeftLegIK.tip_bone)))).origin
	var right_foot_position : Vector3 = (character_skeleton.global_transform * character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(RightLegIK.tip_bone)))).origin
	if debug:
		DebugDraw3D.draw_sphere(left_foot_position, 0.1, Color.RED, 0.0)
		DebugDraw3D.draw_sphere(right_foot_position, 0.1, Color.RED, 0.0)
	if stride_warping_enable and is_on_floor:
		if debug:
			DebugDraw3D.draw_sphere((character_skeleton.global_transform * character_skeleton.get_bone_global_pose_override(character_skeleton.find_bone(String(LeftLegIK.tip_bone)))).origin, 0.075, Color.GREEN, 0.0)
			DebugDraw3D.draw_sphere((character_skeleton.global_transform * character_skeleton.get_bone_global_pose_override(character_skeleton.find_bone(String(RightLegIK.tip_bone)))).origin, 0.075, Color.GREEN, 0.0)
		stride_warping(LeftLegIKTarget, character_skeleton, hips_bone_name, String(LeftLegIK.tip_bone), String(LeftLegIK.root_bone), left_leg_ground_normal_ray_cast.get_collision_normal() if left_leg_ground_normal_ray_cast.is_colliding() else Vector3.UP)
		stride_warping(RightLegIKTarget, character_skeleton, hips_bone_name, String(RightLegIK.tip_bone), String(RightLegIK.root_bone), right_leg_ground_normal_ray_cast.get_collision_normal() if right_leg_ground_normal_ray_cast.is_colliding() else Vector3.UP)
	else:
		if debug:
			DebugDraw3D.draw_sphere(left_foot_position, 0.075, Color.GREEN, 0.0)
			DebugDraw3D.draw_sphere(right_foot_position, 0.075, Color.GREEN, 0.0)

	if slope_warping_enable and is_on_floor:
		slope_warping(LeftLegIKTarget, left_target_rotation, left_leg_ground_normal_ray_cast, slope_warping_raycast_left, slope_warping_raycast_left_touch_detection, slope_warping_bone_attachment_left_foot, 0)
		slope_warping(RightLegIKTarget, right_target_rotation, right_leg_ground_normal_ray_cast, slope_warping_raycast_right, slope_warping_raycast_right_touch_detection, slope_warping_bone_attachment_right_foot, 1)


	set_orientation_warping_direction(orientation_warping_enable, orientation_warping_camera_h_object, character_velocity, orientation_warping_turn_rate, get_physics_process_delta_time())
	orientation_warping(orientation_warping_enable, character_skeleton, hips_bone_name, orientation_warping_spine_bones_names, orientation_warping_offset)

	# Adjust ground touch raycast length for slopes
	if left_leg_ground_normal_ray_cast.get_collision_normal() != Vector3.UP:
		slope_warping_raycast_left_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length + abs(left_target_rotation.rotation.x)/10.0 
	else:
		slope_warping_raycast_left_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length
		
	if right_leg_ground_normal_ray_cast.get_collision_normal() != Vector3.UP:
		slope_warping_raycast_right_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length + abs(right_target_rotation.rotation.x)/10.0
	else:
		slope_warping_raycast_right_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length


## For Predicting Stop Location
## v is velocity. t is time. a is acceleration
func CalculateStopLocation(deacceleration:float) -> Vector3:
	var time : float = CalculateStopTime(deacceleration)
	## it uses a linear equation : d = v*t + 0.5 * a * t^2
	var predictied_distance_before_stop : Vector3 = (character_velocity * time + 0.5*(-deacceleration*character_velocity.normalized())*pow(time,2))
	var stop_position : Vector3 = character_position + predictied_distance_before_stop
	if debug:
		DebugDraw3D.draw_sphere(stop_position+Vector3(0, 0.75, 0), 0.3, Color.RED, 3.0)
	return stop_position

func CalculateStopTime(deacceleration:float) -> float:
	var time : float = character_velocity.length() / deacceleration
	return time


var previous_direction : float
var orientation_direction : float
var cleared_override : bool = true

#just sets the orientation warping direction, this isn't a specific algorithm,
#just my way of how the character should walk.
func set_orientation_warping_direction(enabled:bool, CameraObject, Velocity : Vector3, turn_rate : float, delta:float):
	if is_equal_approx(character_velocity.length(),0.0) or !orientation_warping_enable:
		orientation_direction = 0
		rotation.y = 0
		return
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
	rotation.y = orientation_direction

func orientation_warping(enabled:bool, character_skeleton:Skeleton3D, Hip :String= "Hips", Spines :Array[String]= ["Spine","Spine1","Spine2"], Offset := 0.0):
	
	if !enabled and !cleared_override:
		set_bone_y_rotation(character_skeleton,Hip,0)
		for bone in Spines:
			set_bone_y_rotation(character_skeleton,bone,0)
		cleared_override = true
	if !enabled:
		return
	cleared_override = false
	#Orient bones to face the forward direction
	set_bone_y_rotation(character_skeleton,Hip,orientation_direction)
	for bone in Spines:
		set_bone_y_rotation(character_skeleton,bone,-(orientation_direction/(Spines.size()))+Offset)


func set_bone_y_rotation(skeleton:Skeleton3D,bone_name:String, y_rot:float):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose(bone)
	bone_transform = bone_transform.rotated(Vector3(0,1,0), y_rot)
	
	skeleton.set_bone_global_pose(bone, bone_transform)
	

func stride_warping(target:Node3D, skeleton_ref:Skeleton3D, hips_name:String, Foot:String, Thigh:String, floor_normal:Vector3 = Vector3.UP):
	#add_sibling(test_sphere)
	#add_sibling(test_sphere1)
	
	#skeleton_ref.clear_bones_local_pose_override()
	var distance_in_each_frame = (character_velocity*Vector3(1,0,1)).rotated(Vector3.UP,skeleton_ref.global_transform.basis.get_euler().y).length() 
	var hips = skeleton_ref.find_bone(hips_name)
	var hips_transform = skeleton_ref.get_bone_pose(hips)
	
	var hips_distance_to_ground
	var stride_scale : float = 1.0
	#Get Bones
	var bone = skeleton_ref.find_bone(Foot)
	var bone_transform = skeleton_ref.get_bone_global_pose(bone)
	var thigh_bone = skeleton_ref.find_bone(Thigh)
	var thigh_transform = skeleton_ref.get_bone_global_pose(thigh_bone)
	var thigh_angle = thigh_transform.basis.get_euler().x
	
	#Calculate
	var stride_direction : Vector3 = Vector3.FORWARD # important to use in orientation warping
	var stride_warping_plane_origin = Plane(floor_normal, bone_transform.origin).intersects_ray(thigh_transform.origin,Vector3.DOWN)
#		print(stride_warping_plane_origin)
	if stride_warping_plane_origin == null:
		return #Failed to get a plane origin/ we are probably in air

	var scale_origin = Plane(stride_direction,stride_warping_plane_origin).project(bone_transform.origin)
	var anim_speed = pow(hips_transform.origin.distance_to(bone_transform.origin),2) - pow(hips_transform.origin.y,2) 
	anim_speed = sqrt(abs(anim_speed))
	stride_scale = clampf(distance_in_each_frame/4/anim_speed,0.0,2.0)
	var foot_warped_location : Vector3 = scale_origin + (bone_transform.origin - scale_origin) * stride_scale
	# Apply
	if stride_scale > 0.1:
		target.position = lerp(target.position, foot_warped_location, 1)

var updated_raycast_pos : Array[bool]
func foot_look_at_y(from:Vector3, to:Vector3, up_ref:Vector3 = Vector3.UP) -> Basis:
	var forward = (to - from).normalized()
	var right = up_ref.normalized().cross(forward).normalized()
	forward = right.cross(up_ref).normalized()
	return Basis(right, up_ref, forward)
func slope_warping(target:Node3D, target_rotation:Node3D, leg_ground_normal_ray_cast:RayCast3D, raycast:RayCast3D, touch_raycast:RayCast3D, no_raycast_pos, leg_number:int):
	if updated_raycast_pos.size() < leg_number+1:
		updated_raycast_pos.resize(leg_number+1)

	if slope_warping_feet_locking_enable:
		if touch_raycast.is_colliding() and character_velocity.length() > 0.5:
			if updated_raycast_pos[leg_number] == false:
				raycast.global_position = no_raycast_pos.global_position + Vector3(0.0,0.25,0.0) # Set the lock position
				updated_raycast_pos[leg_number] = true
		else:
			updated_raycast_pos[leg_number] = false
			# Update position to not let the leg yeet towards the old far location
			raycast.global_position = lerp(raycast.global_position, no_raycast_pos.global_position + Vector3(0.0,0.25,0.0), get_process_delta_time()*20) #smoothly lerp out of lock
	else:
		raycast.global_position = no_raycast_pos.global_position + Vector3(0.0,0.25,0.0)
		#character_skeleton.get_bone_global_pose(no_raycast_pos.bone_idx)
	if raycast.is_colliding() and (touch_raycast.is_colliding() or character_velocity.length()<1.0): #if raycast is on ground
		var hit_point = raycast.get_collision_point() + Vector3.UP*slope_warping_foot_height_offset #gets Y position of where the ground is.
		if character_velocity.length() > 0.5 and slope_warping_feet_locking_enable:
			target.global_transform.origin = lerp(target.global_transform.origin, hit_point, 1) #sets the target to the position of the hitpoint which helps locking too
		else:
			target.global_transform.origin.y = hit_point.y #sets the target to the y position of the hitpoint
		var up_ref = raycast.get_collision_normal()
		target_rotation.global_transform.basis = foot_look_at_y(Vector3.ZERO, character_skeleton.global_transform.basis.z.rotated(Vector3.UP, orientation_direction), leg_ground_normal_ray_cast.get_collision_normal())
