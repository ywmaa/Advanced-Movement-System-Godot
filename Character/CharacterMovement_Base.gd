extends CharacterBody3D
class_name CharacterMovement


#####################################
@export var mesh_path : NodePath
@export var skeleton_path : NodePath
#Refrences
@onready var mesh_ref = get_node(mesh_path)
@onready var anim_ref : AnimBlend = get_node("AnimationTree")
@onready var skeleton_ref : Skeleton3D = get_node(skeleton_path)
@onready var collision_shape_ref = $CollisionShape3D
@onready var bonker = $CollisionShape3D/HeadBonker
@onready var camera_root : CameraRoot = $CameraRoot
#####################################



#####################################
#Movement Settings
@export var AI := false

@export var is_flying := false
@export var gravity := 9.8

@export var tilt := false
@export var tilt_power := 1.0

@export var ragdoll := false :
	get: return ragdoll
	set(Newragdoll):
		ragdoll = Newragdoll
		if ragdoll == true:
			if skeleton_ref:
				skeleton_ref.physical_bones_start_simulation()
		else:
			if skeleton_ref:
				skeleton_ref.physical_bones_stop_simulation()


@export var jump_magnitude := 10.0
@export var roll_magnitude := 17.0

var default_height := 2.0
var crouch_height := 1.0

@export var crouch_switch_speed := 5.0 

@export var rotation_in_place_min_angle := 90.0 

#Movement Values Settings
#you could play with the values to achieve different movement settings
var deacceleration := 8.0
var acceleration_reducer := 4.0
var movement_data = {
	normal = {
		looking_direction = {
			standing = {
				walk_speed = 1.75,
				run_speed = 3.75,
				sprint_speed = 6.5,
				
				walk_acceleration = 20.0/acceleration_reducer,
				run_acceleration = 20.0/acceleration_reducer,
				sprint_acceleration = 7.5/acceleration_reducer,
				
				idle_rotation_rate = 0.5,
				walk_rotation_rate = 4.0,
				run_rotation_rate = 5.0,
				sprint_rotation_rate = 20.0,
			},

			crouching = {
				walk_speed = 1.5,
				run_speed = 2,
				sprint_speed = 3,
				
				walk_acceleration = 25.0/acceleration_reducer,
				run_acceleration = 25.0/acceleration_reducer,
				sprint_acceleration = 5.0/acceleration_reducer,
				
				idle_rotation_rate = 0.5,
				walk_rotation_rate = 4.0,
				run_rotation_rate = 5.0,
				sprint_rotation_rate = 20.0,
			}
		},
		
		
		
		
		
		velocity_direction = {
			standing = {
				walk_speed = 1.51,#Anim walk speed 1.48
				run_speed = 3.75,
				sprint_speed = 10.0,
				
				#Nomral Acceleration
				walk_acceleration = 20.0/acceleration_reducer,
				run_acceleration = 20.0/acceleration_reducer, 
				sprint_acceleration = 7.5/acceleration_reducer,
				
				#Responsive Rotation
				idle_rotation_rate = 5.0,
				walk_rotation_rate = 8.0,
				run_rotation_rate = 12.0, 
				sprint_rotation_rate = 20.0,
			},

			crouching = {
				walk_speed = 1.5,
				run_speed = 2,
				sprint_speed = 3,
				
				#Responsive Acceleration
				walk_acceleration = 25.0/acceleration_reducer,
				run_acceleration = 25.0/acceleration_reducer,
				sprint_acceleration = 5.0/acceleration_reducer,
				
				#Nomral Rotation
				idle_rotation_rate = 0.5,
				walk_rotation_rate = 4.0,
				run_rotation_rate = 5.0,
				sprint_rotation_rate = 20.0,
			}
		},
		
		
		
		
		
		
		aiming = {
			standing = {
				walk_speed = 1.65,
				run_speed = 3.75,
				sprint_speed = 6.5,
				
				walk_acceleration = 20.0/acceleration_reducer,
				run_acceleration = 20.0/acceleration_reducer,
				sprint_acceleration = 7.5/acceleration_reducer,
				
				idle_rotation_rate = 0.5,
				walk_rotation_rate = 4.0,
				run_rotation_rate = 5.0,
				sprint_rotation_rate = 20.0,
			},

			crouching = {
				walk_speed = 1.5,
				run_speed = 2,
				sprint_speed = 3,
				
				walk_acceleration = 25.0/acceleration_reducer,
				run_acceleration = 25.0/acceleration_reducer,
				sprint_acceleration = 5.0/acceleration_reducer,
				
				idle_rotation_rate = 0.5,
				walk_rotation_rate = 4.0,
				run_rotation_rate = 5.0,
				sprint_rotation_rate = 20.0,
			}
		}
	}
}
#####################################














#####################################
#for logic #it is better not to change it if you don't want to break the system / only change it if you want to redesign the system
var actual_acceleration :Vector3
var input_acceleration :Vector3

var vertical_velocity :Vector3 

var input_velocity :Vector3

var tiltVector : Vector3

var is_moving := false
var input_is_moving := false

var head_bonked := false

var is_rotating_in_place := false
var rotation_difference_camera_mesh : float
var IsMovingBackwardRelativeToCamera : bool

var aim_rate_h :float


var current_movement_data = {
	walk_speed = 1.75,
	run_speed = 3.75,
	sprint_speed = 6.5,

	walk_acceleration = 20.0,
	run_acceleration = 20.0,
	sprint_acceleration = 7.5,

	idle_rotation_rate = 0.5,
	walk_rotation_rate = 4.0,
	run_rotation_rate = 5.0,
	sprint_rotation_rate = 20.0,
}
#####################################



#status
var movement_state = Global.movement_state.grounded
var movement_action = Global.movement_action.none

@export var rotation_mode = Global.rotation_mode :
	get: return rotation_mode
	set(Newrotation_mode):
		rotation_mode = Newrotation_mode
		update_character_movement()
		
@export var gait = Global.gait :
	get: return gait
	set(Newgait):
		gait = Newgait
		update_character_movement()
@export var stance = Global.stance
@export var overlay_state = Global.overlay_state

@export var AnimTurnLeft : String = "TurnLeft"
@export var AnimTurnRight : String = "TurnRight"

#####################################
#IK

func update_animations():
#	var anim_player : AnimationPlayer = anim_ref.get_node(anim_ref.anim_player)
	anim_ref.tree_root.get_node("AnimTurnLeft").animation = AnimTurnLeft
	anim_ref.tree_root.get_node("AnimTurnRight").animation = AnimTurnRight
func update_character_movement():
	match rotation_mode:
		Global.rotation_mode.velocity_direction:
			if skeleton_ref:
				skeleton_ref.modification_stack.enabled = false
			tilt = false
			match stance:
				Global.stance.standing:
					current_movement_data = movement_data.normal.velocity_direction.standing
				Global.stance.crouching:
					current_movement_data = movement_data.normal.velocity_direction.crouching
					
					
		Global.rotation_mode.looking_direction:
			if skeleton_ref:
				skeleton_ref.modification_stack.enabled = false #Change to true when Godot fixes the bug.
			tilt = true
			match stance:
				Global.stance.standing:
					current_movement_data = movement_data.normal.looking_direction.standing
				Global.stance.crouching:
					current_movement_data = movement_data.normal.looking_direction.crouching
					
					
		Global.rotation_mode.aiming:
			match stance:
				Global.stance.standing:
					current_movement_data = movement_data.normal.aiming.standing
				Global.stance.crouching:
					current_movement_data = movement_data.normal.aiming.crouching
#####################################

var previous_aim_rate_h :float

func _ready():

	update_character_movement()
#	update_animations()
func _physics_process(delta):
#	animation_speed_warping()
	IsMovingBackwardRelativeToCamera = false if -velocity.rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y).z >= -0.1 else true
	skeleton_ref.clear_bones_global_pose_override() # this is very important when using orientation warping, because the said function overrides the bones, so we need to reset it in a new frame
	
	head_bonked = bonker.is_colliding()
	#
	aim_rate_h = abs(($CameraRoot.HObject.rotation.y - previous_aim_rate_h) / delta)
	previous_aim_rate_h = $CameraRoot.HObject.rotation.y
	#
	#Debug()
	match movement_state:
		Global.movement_state.none:
			pass
		Global.movement_state.grounded:
			#------------------ Rotate Character Mesh ------------------#
			match movement_action:
				Global.movement_action.none:
					match rotation_mode:
							Global.rotation_mode.velocity_direction: 
								if (is_moving and input_is_moving) or (get_velocity() * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(velocity,calc_grounded_rotation_rate(),delta)
								is_rotating_in_place = false
								skeleton_ref.clear_bones_global_pose_override()
							Global.rotation_mode.looking_direction:
								if (is_moving and input_is_moving) or (get_velocity() * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(-$CameraRoot.HObject.transform.basis.z if gait != Global.gait.sprinting else velocity,calc_grounded_rotation_rate(),delta)
									if gait != Global.gait.sprinting:
										pose_warping.orientation_warping($CameraRoot.HObject,velocity,self,skeleton_ref,"Hips",["Spine","Spine1","Spine2"],1.0)
								rotate_in_place_check()
							Global.rotation_mode.aiming:
								if gait == Global.gait.sprinting: # character can't sprint while aiming
									gait = Global.gait.running
								if (is_moving and input_is_moving) or (get_velocity() * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(-$CameraRoot.HObject.transform.basis.z,calc_grounded_rotation_rate(),delta)
								
								pose_warping.orientation_warping($CameraRoot.HObject,velocity,self,skeleton_ref)
								rotate_in_place_check()
				Global.movement_action.rolling:
					if input_is_moving == true:
						smooth_character_rotation(input_acceleration ,2.0,delta)
						
		
		Global.movement_state.in_air:
			#------------------ Rotate Character Mesh In Air ------------------#
			match rotation_mode:
					Global.rotation_mode.velocity_direction: 
						smooth_character_rotation(velocity if (get_velocity() * Vector3(1.0,0.0,1.0)).length() > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
					Global.rotation_mode.looking_direction:
						smooth_character_rotation(velocity if (get_velocity() * Vector3(1.0,0.0,1.0)).length() > 1.0 else  -$CameraRoot.HObject.transform.basis.z,5.0,delta)
					Global.rotation_mode.aiming:
						smooth_character_rotation(-$CameraRoot.HObject.transform.basis.z ,15.0,delta)
			#------------------ Mantle Check ------------------#
			if input_is_moving == true:
				mantle_check()
		Global.movement_state.mantling:
			pass
		Global.movement_state.ragdoll:
			pass
	

	#------------------ Crouch ------------------#
	if stance == Global.stance.crouching:
		bonker.transform.origin.y -= crouch_switch_speed * delta
		collision_shape_ref.shape.height -= crouch_switch_speed * delta /2
		mesh_ref.transform.origin.y += crouch_switch_speed * delta /1.5
	elif stance == Global.stance.standing and not head_bonked:
		bonker.transform.origin.y += crouch_switch_speed * delta 
		collision_shape_ref.shape.height += crouch_switch_speed * delta /2
		mesh_ref.transform.origin.y -= crouch_switch_speed * delta /1.5
		
	bonker.transform.origin.y = clamp(bonker.transform.origin.y,0.5,0.1)
	mesh_ref.transform.origin.y = clamp(mesh_ref.transform.origin.y,0.0,0.5)
	collision_shape_ref.shape.height = clamp(collision_shape_ref.shape.height,crouch_height,default_height)
	

	#------------------ Gravity ------------------#
	if is_flying == false:
		velocity.y =  lerp(velocity.y,vertical_velocity.y - get_floor_normal().y,delta * gravity)
		move_and_slide()
		
	if is_on_floor() and is_flying == false:
		movement_state = Global.movement_state.grounded 
		vertical_velocity = -get_floor_normal() * 10
	else:
		movement_state = Global.movement_state.in_air
		vertical_velocity += Vector3.DOWN * gravity * delta
#		if vertical_velocity < -20:
#			roll()
	if is_on_ceiling():
		vertical_velocity.y = 0


func smooth_character_rotation(Target:Vector3,nodelerpspeed,delta):
	mesh_ref.rotation.y = lerp_angle(mesh_ref.rotation.y, atan2(Target.x,Target.z) , delta * nodelerpspeed)
func animation_speed_warping(): #this is currently being worked on and tested, so I don't reccomend using it.
	var distance_in_each_frame = -velocity.rotated(Vector3.UP,mesh_ref.transform.basis.get_euler().y)*get_physics_process_delta_time()
	var boneright = skeleton_ref.find_bone("RightFoot")
	var bone_transformright = skeleton_ref.get_bone_global_pose(boneright)
	var boneleft = skeleton_ref.find_bone("LeftFoot")
	var bone_transformleft = skeleton_ref.get_bone_global_pose(boneleft)
	var difference = abs(bone_transformright.origin.z) - abs(bone_transformleft.origin.z)
#	print(distance_in_each_frame.length()*2*10/30)
#	print(difference*1.1833*60)
#	print(abs(difference) < abs(distance_in_each_frame))
#	if abs(difference) > abs(distance_in_each_frame):
#		bone_transformright.origin.z = bone_transformright.origin.z - abs(distance_in_each_frame)
#		skeleton_ref.set_bone_global_pose_override(boneright, bone_transformright,1.0,true)
#		bone_transformleft.origin.z = bone_transformleft.origin.z - abs(distance_in_each_frame)
#		skeleton_ref.set_bone_global_pose_override(boneleft, bone_transformleft,1.0,true)
#	if abs(difference) < abs(distance_in_each_frame):
#		bone_transformright.origin.z = bone_transformright.origin.z + abs(distance_in_each_frame)
#		skeleton_ref.set_bone_global_pose_override(boneright, bone_transformright,1.0,true)
#		bone_transformleft.origin.z = bone_transformleft.origin.z + abs(distance_in_each_frame)
#		skeleton_ref.set_bone_global_pose_override(boneleft, bone_transformleft,1.0,true)
func calc_grounded_rotation_rate():
	
	if input_is_moving == true:
		match gait:
			Global.gait.walking:
				return lerp(current_movement_data.idle_rotation_rate,current_movement_data.walk_rotation_rate, Global.map_range_clamped((get_velocity() * Vector3(1.0,0.0,1.0)).length(),0.0,current_movement_data.walk_speed,0.0,1.0)) * clamp(aim_rate_h,1.0,3.0)
			Global.gait.running:
				return lerp(current_movement_data.walk_rotation_rate,current_movement_data.run_rotation_rate, Global.map_range_clamped((get_velocity() * Vector3(1.0,0.0,1.0)).length(),current_movement_data.walk_speed,current_movement_data.run_speed,1.0,2.0)) * clamp(aim_rate_h,1.0,3.0)
			Global.gait.sprinting:
				return lerp(current_movement_data.run_rotation_rate,current_movement_data.sprint_rotation_rate,  Global.map_range_clamped((get_velocity() * Vector3(1.0,0.0,1.0)).length(),current_movement_data.run_speed,current_movement_data.sprint_speed,2.0,3.0)) * clamp(aim_rate_h,1.0,2.5)
	else:
		return current_movement_data.idle_rotation_rate * clamp(aim_rate_h,1.0,3.0)



func rotate_in_place_check():
	if !input_is_moving:
		var CameraAngle = Quaternion(Vector3(0,$CameraRoot.HObject.rotation.y,0)) 
		var MeshAngle = Quaternion(Vector3(0,mesh_ref.rotation.y,0)) 
		rotation_difference_camera_mesh = rad2deg(MeshAngle.angle_to(CameraAngle) - PI)
		if (CameraAngle.dot(MeshAngle)) > 0:
			rotation_difference_camera_mesh *= -1
		
		if floor(abs(rotation_difference_camera_mesh)) > rotation_in_place_min_angle:
			is_rotating_in_place = true
			smooth_character_rotation(-$CameraRoot.HObject.transform.basis.z,calc_grounded_rotation_rate(),get_physics_process_delta_time()) 
		else:
			is_rotating_in_place = false
	else:
		is_rotating_in_place = false

func ik_look_at(position: Vector3):
	var lookatobject = mesh_ref.get_node("LookAtObject")
	if lookatobject:
		lookatobject.position = position


var PrevVelocity :Vector3
func add_movement_input(direction: Vector3, Speed: float , Acceleration: float) -> void:
	if is_flying == false:
		velocity.x = lerp(velocity.x, direction.x * Speed, Acceleration * get_physics_process_delta_time())
		velocity.z = lerp(velocity.z, direction.z * Speed, Acceleration * get_physics_process_delta_time())
	else:
		set_velocity(get_velocity().lerp(direction * Speed, Acceleration * get_physics_process_delta_time()))
		move_and_slide()
	input_velocity = Speed * direction
	input_is_moving = Speed > 0.0
	input_acceleration = Acceleration * direction
	#
	actual_acceleration = (velocity - PrevVelocity)  / (Acceleration * get_physics_process_delta_time())
	PrevVelocity = velocity
	#
	
	#tiltCharacterMesh
	if tilt == true:
		var MovementDirectionRelativeToCamera = input_velocity.normalized().rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y)
		var IsMovingBackwardRelativeToCamera = false if input_velocity.rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y).z >= -0.1 else true
		if IsMovingBackwardRelativeToCamera:
			MovementDirectionRelativeToCamera.x = MovementDirectionRelativeToCamera.x * -1

		tiltVector = (MovementDirectionRelativeToCamera).rotated(Vector3.UP,-PI/2) / (8.0/tilt_power)
		mesh_ref.rotation.x = lerp(mesh_ref.rotation.x,tiltVector.x,Acceleration * get_physics_process_delta_time())
		mesh_ref.rotation.z = lerp(mesh_ref.rotation.z,tiltVector.z,Acceleration * get_physics_process_delta_time())
	#



func mantle_check():
	pass

func jump() -> void:
	vertical_velocity = Vector3.UP * jump_magnitude



