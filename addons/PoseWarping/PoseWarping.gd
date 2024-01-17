@tool
extends Node
class_name PoseWarping
## a Node that Handles Pose Warping for character for enhanced animations
## Must be a child of Skeleton3D

## Character Node, either CharacterBody3D or RigidBody3D
@export var character_node : PhysicsBody3D
## The Character Skeleton that is going to be modified
@onready var character_skeleton : Skeleton3D = get_parent()
## SkeletonIK3D Node that adjusts the left leg IK
@export var LeftLegIK : SkeletonIK3D
## SkeletonIK3D Node that adjusts the right leg IK
@export var RightLegIK : SkeletonIK3D
## Hips bone name, Please Write the correct hips bone name according to your skeleton.
@export var hips_bone_name : String = "Hips"
## MUST BE MODIFIED THROUGH MOVEMENT SCRIPT TO MATCH PLAYER MOVEMENT SPEED
@export var character_velocity : Vector3


@onready var LeftLegIKTarget : Marker3D = $LeftIKTarget
@onready var RightLegIKTarget : Marker3D = $RightIKTarget

@export_subgroup("Orientation Warping", "orientation_warping_")
## Orientation Warping is a system that adjusts the character's Legs and Hips (Lower body)
## To adapt to character movement direction.
@export var orientation_warping_enable : bool
## This is tthe object that contains the camera horizontal rotation
## it could be the camera object itself.
@export var orientation_warping_camera_h_object : Node3D
## Spine Bones Names, Please Write the correct bone names for all of the spine bones according to your skeleton.
@export var orientation_warping_spine_bones_names : Array[String] = ["Spine","Spine1","Spine2"] 
## An offset added to the Spine Bones rotation relative to camera forward
@export var orientation_warping_offset := 0.0 
## 
@export var orientation_warping_turn_rate :float= 10.0


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
@onready var slope_warping_raycast_left : RayCast3D = $LeftLegRayCast
@onready var slope_warping_bone_attachment_left_foot : BoneAttachment3D = $LeftFootAttachment
@onready var slope_warping_raycast_right_touch_detection : RayCast3D = $RightFootAttachment/RightLegTouchRayCast
@onready var slope_warping_raycast_right : RayCast3D = $RightLegRayCast
@onready var slope_warping_bone_attachment_right_foot : BoneAttachment3D = $RightFootAttachment
@export var slope_warping_foot_height_offset : float = 0.1
#func _init(_character_node:PhysicsBody3D, _skeleton:Skeleton3D, _LeftLegIK:SkeletonIK3D, _RightLegIK:SkeletonIK3D):
	#character_node = _character_node
	#character_skeleton = _skeleton
	#LeftLegIK = _LeftLegIK
	#RightLegIK = _RightLegIK

func _get_configuration_warnings():
	if not get_parent() is Skeleton3D:
		return ["Parent Must be Skeleton3D."]

func _ready():
	if not get_parent() is Skeleton3D:
		assert(false, "Parent Must be Skeleton3D.")
		update_configuration_warnings()
	if not character_node is CharacterBody3D and not character_node is RigidBody3D:
		assert(false, "Character Node Must be either CharacterBody3D or RigidBody3D, please choose the right node from the inspector.")
	slope_warping_bone_attachment_left_foot.set_external_skeleton(character_skeleton.get_path())
	slope_warping_bone_attachment_left_foot.bone_name = String(LeftLegIK.tip_bone)
	slope_warping_bone_attachment_right_foot.set_external_skeleton(character_skeleton.get_path())
	slope_warping_bone_attachment_right_foot.bone_name = String(RightLegIK.tip_bone)
	
	slope_warping_raycast_left_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length
	slope_warping_raycast_right_touch_detection.target_position.y = slope_warping_foot_ground_touch_raycast_length

	slope_warping_raycast_left.add_exception(character_node)
	slope_warping_raycast_right.add_exception(character_node)
	slope_warping_raycast_left_touch_detection.add_exception(character_node)
	slope_warping_raycast_right_touch_detection.add_exception(character_node)
	
	LeftLegIK.target_node = LeftLegIKTarget.get_path()
	RightLegIK.target_node = RightLegIKTarget.get_path()

func _process(delta):
	#if Engine.is_editor_hint():
		#return
	if stride_warping_enable or slope_warping_enable:
		var bone_transform_left = character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(LeftLegIK.tip_bone)))
		var bone_transform_right = character_skeleton.get_bone_global_pose_no_override(character_skeleton.find_bone(String(RightLegIK.tip_bone)))
		LeftLegIKTarget.transform = bone_transform_left
		RightLegIKTarget.transform = bone_transform_right
		if !LeftLegIK.is_running():
			LeftLegIK.start()
		if !RightLegIK.is_running():
			RightLegIK.start()
	else:
		if LeftLegIK.is_running():
			LeftLegIK.stop()
		if RightLegIK.is_running():
			RightLegIK.stop()
			
	if stride_warping_enable:
		stride_warping(LeftLegIKTarget, character_node.get_floor_normal(), character_skeleton, hips_bone_name, String(LeftLegIK.tip_bone), String(LeftLegIK.root_bone))
		stride_warping(RightLegIKTarget, character_node.get_floor_normal(), character_skeleton, hips_bone_name, String(RightLegIK.tip_bone), String(RightLegIK.root_bone))
	if slope_warping_enable:
		slope_warping(LeftLegIKTarget, slope_warping_raycast_left, slope_warping_raycast_left_touch_detection, slope_warping_bone_attachment_left_foot, 0)
		slope_warping(RightLegIKTarget, slope_warping_raycast_right, slope_warping_raycast_right_touch_detection, slope_warping_bone_attachment_right_foot, 1)
	if orientation_warping_enable:
		#var orientation_warping_condition = rotation_mode != Global.rotation_mode.velocity_direction and movement_state == Global.movement_state.grounded and movement_action == Global.movement_action.none and gait != Global.gait.sprinting and input_is_moving
		orientation_warping(true, orientation_warping_camera_h_object, character_velocity, character_skeleton, hips_bone_name, orientation_warping_spine_bones_names, 0.0, delta)




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
func orientation_warping(enabled:bool,CameraObject, Velocity:Vector3, character_skeleton:Skeleton3D, Hip :String= "Hips", Spines :Array[String]= ["Spine","Spine1","Spine2"], Offset := 0.0, delta :float= 1.0, turn_rate :float= 10.0):
	
	if !enabled and !cleared_override:
		set_bone_y_rotation(character_skeleton,Hip,0,false)
		for bone in Spines:
			set_bone_y_rotation(character_skeleton,bone,0,false)
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
	
	set_bone_y_rotation(character_skeleton,Hip,orientation_direction)
	for bone in Spines:
		set_bone_y_rotation(character_skeleton,bone,(-orientation_direction/(Spines.size()))+Offset)
		
	
func set_bone_y_rotation(skeleton:Skeleton3D,bone_name:String, y_rot:float, presistant:bool=true):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose_no_override(bone)
	bone_transform = bone_transform.rotated(Vector3(0,1,0), y_rot)
	
	skeleton.set_bone_global_pose_override(bone, bone_transform,1.0,presistant)
	

func stride_warping(target:Node3D, floor_normal:Vector3, skeleton_ref:Skeleton3D, hips_name:String, Foot:String, Thigh:String):
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
	var bone_transform = skeleton_ref.get_bone_global_pose_no_override(bone)
	
	var thigh_bone = skeleton_ref.find_bone(Thigh)
	var thigh_transform = skeleton_ref.get_bone_global_pose_no_override(thigh_bone)
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
func slope_warping(target:Node3D, raycast:RayCast3D, touch_raycast:RayCast3D, no_raycast_pos, leg_number:int):
	if updated_raycast_pos.size() < leg_number+1:
		updated_raycast_pos.resize(leg_number+1)

	if slope_warping_feet_locking_enable:
		if touch_raycast.is_colliding():
			if updated_raycast_pos[leg_number] == false:
				raycast.global_position = no_raycast_pos.global_position + Vector3(0.0,0.25,0.0)
				updated_raycast_pos[leg_number] = true
		else:
			updated_raycast_pos[leg_number] = false
			# Update position to not let the leg yeet towards the old far location
			raycast.global_position = lerp(raycast.global_position, no_raycast_pos.global_position + Vector3(0.0,0.25,0.0), get_process_delta_time()*20)
	else:
		raycast.global_position = no_raycast_pos.global_position + Vector3(0.0,0.25,0.0)

	if raycast.is_colliding() and (touch_raycast.is_colliding() or character_velocity.length()<1.0): #if raycast is on ground
		var hit_point = raycast.get_collision_point() + Vector3.UP*slope_warping_foot_height_offset #gets Y position of where the ground is.
		target.global_transform.origin = hit_point #sets the target to the y position of the hitpoint
		#if raycast.get_collision_normal() != Vector3.UP:
		#var relative_normal = hit_point * raycast.get_collision_normal()
		#target.look_at(relative_normal, Vector3.UP)
			#target.global_transform = _basis_from_normal(target.global_transform, raycast.get_collision_normal())
			#target.rotation += Vector3(-35, 0, 180)
		#target.global_transform.basis = foot_look_at_y(Vector3.ZERO, character_skeleton.global_transform.basis.z, raycast.get_collision_normal())
	#else:
		#raycast.global_transform.origin = target.global_transform.origin #if the raycast not colliding, the player is in the air and so the target position is set to the no_raycast_pos
