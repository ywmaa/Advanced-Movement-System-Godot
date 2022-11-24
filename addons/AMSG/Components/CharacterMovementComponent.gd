extends Node
class_name CharacterMovementComponent


#####################################
@export_category("Refrences")
@export var character_path : NodePath
@export var mesh_path : NodePath
@export var skeleton_path : NodePath
@export var anim_tree_path : NodePath
@export var camera_component : NodePath
@export var collision_shape_path : NodePath
#Refrences
@onready var mesh_ref = get_node(mesh_path)
@onready var anim_ref : AnimBlend = get_node(anim_tree_path)
@onready var skeleton_ref : Skeleton3D = get_node(skeleton_path)
@onready var collision_shape_ref = get_node(collision_shape_path)
#@onready var bonker = $CollisionShape3D/HeadBonker
@onready var camera_root : CameraComponent = get_node(camera_component)
@onready var character_node : CharacterBody3D = get_node(character_path)
#####################################



#####################################
#Movement Settings
@export_category("Movement Data")
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


@export var jump_magnitude := 5.0
@export var max_stair_climb_height : float = 0.5
@export var max_close_stair_distance : float = 0.75
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
				walk_speed = 1.75,
				run_speed = 3.75,
				sprint_speed = 6.5,
				
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

var actual_velocity :Vector3
var input_velocity :Vector3
var movement_direction

var tiltVector : Vector3

var is_moving := false
var input_is_moving := false

var head_bonked := false

var is_rotating_in_place := false
var rotation_difference_camera_mesh : float

var aim_rate_h :float

var is_moving_on_stair :bool


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

#animation
var animation_is_moving_backward_relative_to_camera : bool
var animation_velocity : Vector3

#status
var movement_state = Global.movement_state.grounded
var movement_action = Global.movement_action.none
@export_category("States")
@export var rotation_mode : Global.rotation_mode = Global.rotation_mode.velocity_direction :
	get: return rotation_mode
	set(Newrotation_mode):
		rotation_mode = Newrotation_mode
		update_character_movement()
		
		
@export var gait : Global.gait = Global.gait.walking :
	get: return gait
	set(Newgait):
		gait = Newgait
		update_character_movement()
@export var stance : Global.stance = Global.stance.standing :
	set(Newstance):
		stance = Newstance
		update_character_movement()
@export var overlay_state = Global.overlay_state

@export_category("Animations")
@export var TurnLeftAnim : String = "TurnLeft":
	set(value):
		TurnLeftAnim = value
		update_animations()
@export var TurnRightAnim : String = "TurnRight":
	set(value):
		TurnRightAnim = value
		update_animations()
@export var FallingStartAnim : String = "FallingStart":
	set(value):
		FallingStartAnim = value
		update_animations()
@export var FallingAnim : String = "Falling":
	set(value):
		FallingAnim = value
		update_animations()
@export var IdleAnim : String = "Idle":
	set(value):
		IdleAnim = value
		update_animations()
@export var WalkForwardAnim : String = "Walk":
	set(value):
		WalkForwardAnim = value
		update_animations()
@export var WalkBackwardAnim : String = "WalkingBackward":
	set(value):
		WalkBackwardAnim = value
		update_animations()
@export var JogForwardAnim : String = "JogForward":
	set(value):
		JogForwardAnim = value
		update_animations()
@export var JogBackwardAnim : String = "Jogbackward":
	set(value):
		JogBackwardAnim = value
		update_animations()
@export var RunAnim : String = "Run":
	set(value):
		RunAnim = value
		update_animations()
@export var StopAnim : String = "RunToStop":
	set(value):
		StopAnim = value
		update_animations()
@export var CrouchIdleAnim : String = "CrouchIdle":
	set(value):
		CrouchIdleAnim = value
		update_animations()
@export var CrouchWalkAnim : String = "CrouchWalkingForward":
	set(value):
		CrouchWalkAnim = value
		update_animations()
#####################################


func update_animations():
	if !anim_ref:
		return
	anim_ref.tree_root.get_node("AnimTurnLeft").animation = TurnLeftAnim
	anim_ref.tree_root.get_node("AnimTurnRight").animation = TurnRightAnim
	anim_ref.tree_root.get_node("InAirState").get_node("FallingStart").animation = FallingStartAnim
	anim_ref.tree_root.get_node("InAirState").get_node("Falling").animation = FallingAnim
	var velocity_direction : AnimationNodeBlendTree = anim_ref.tree_root.get_node("VelocityDirection")
	var standing_states = velocity_direction.get_node("standing")
	standing_states.get_node("Idle").animation = IdleAnim
	standing_states.get_node("Walk").get_node("Forward").animation = WalkForwardAnim
	standing_states.get_node("Walk").get_node("Backward").animation = WalkBackwardAnim
	standing_states.get_node("Jog").get_node("Forward").animation = JogForwardAnim
	standing_states.get_node("Jog").get_node("Backward").animation = JogBackwardAnim
	standing_states.get_node("Run").animation = RunAnim
	standing_states.get_node("Stopping").get_node("StopAnim").animation = StopAnim
	velocity_direction.get_node("crouching").get_node("CrouchIdle").animation = CrouchIdleAnim
	velocity_direction.get_node("crouching").get_node("CrouchWalkingForward").animation = CrouchWalkAnim
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
	update_animations()
	update_character_movement()
var pose_warping_instance = pose_warping.new()
func _process(delta):
	calc_animation_data()
	var orientation_warping_condition = rotation_mode != Global.rotation_mode.velocity_direction and movement_state == Global.movement_state.grounded and movement_action == Global.movement_action.none and gait != Global.gait.sprinting and input_is_moving
	pose_warping_instance.orientation_warping( orientation_warping_condition,camera_root.HObject,animation_velocity,skeleton_ref,"Hips",["Spine","Spine1","Spine2"],0.0,delta)

func _physics_process(delta):
	#Debug()
	#
	aim_rate_h = abs((camera_root.HObject.rotation.y - previous_aim_rate_h) / delta)
	previous_aim_rate_h = camera_root.HObject.rotation.y
	#
#	animation_stride_warping()

	match movement_state:
		Global.movement_state.none:
			pass
		Global.movement_state.grounded:
			#------------------ Rotate Character Mesh ------------------#
			match movement_action:
				Global.movement_action.none:
					match rotation_mode:
							Global.rotation_mode.velocity_direction: 
								if (is_moving and input_is_moving) or (actual_velocity * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(actual_velocity,calc_grounded_rotation_rate(),delta)
							Global.rotation_mode.looking_direction:
								if (is_moving and input_is_moving) or (actual_velocity * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(-camera_root.HObject.transform.basis.z if gait != Global.gait.sprinting else actual_velocity,calc_grounded_rotation_rate(),delta)
								rotate_in_place_check()
							Global.rotation_mode.aiming:
								if (is_moving and input_is_moving) or (actual_velocity * Vector3(1.0,0.0,1.0)).length() > 0.5:
									smooth_character_rotation(-camera_root.HObject.transform.basis.z,calc_grounded_rotation_rate(),delta)
								rotate_in_place_check()
				Global.movement_action.rolling:
					if input_is_moving == true:
						smooth_character_rotation(input_acceleration ,2.0,delta)
		
		Global.movement_state.in_air:
			#------------------ Rotate Character Mesh In Air ------------------#
			match rotation_mode:
					Global.rotation_mode.velocity_direction: 
						smooth_character_rotation(actual_velocity if (actual_velocity * Vector3(1.0,0.0,1.0)).length() > 1.0 else  -camera_root.HObject.transform.basis.z,5.0,delta)
					Global.rotation_mode.looking_direction:
						smooth_character_rotation(actual_velocity if (actual_velocity * Vector3(1.0,0.0,1.0)).length() > 1.0 else  -camera_root.HObject.transform.basis.z,5.0,delta)
					Global.rotation_mode.aiming:
						smooth_character_rotation(-camera_root.HObject.transform.basis.z ,15.0,delta)
			#------------------ Mantle Check ------------------#
			if input_is_moving == true:
				mantle_check()
		Global.movement_state.mantling:
			pass
		Global.movement_state.ragdoll:
			pass
	
	#------------------ Crouch ------------------#
	crouch_update(delta)

	#------------------ Gravity ------------------#
	if is_flying == false:
		character_node.velocity.y =  lerp(character_node.velocity.y,vertical_velocity.y - character_node.get_floor_normal().y,delta * gravity)
		character_node.move_and_slide()
	if character_node.is_on_floor() and is_flying == false:
		movement_state = Global.movement_state.grounded 
		vertical_velocity = -character_node.get_floor_normal() * 10
	else:
		await get_tree().create_timer(0.1).timeout #wait a moment to see if the character lands fast (this means that the character didn't fall, but stepped down a bit.)
		movement_state = Global.movement_state.in_air
		vertical_velocity += Vector3.DOWN * gravity * delta
	if character_node.is_on_ceiling():
		vertical_velocity.y = 0
	#------------------ Stair climb ------------------#
	#stair movement must happen after gravity so it can override in air status
	stair_move()

func crouch_update(delta):
	var direct_state = character_node.get_world_3d().direct_space_state
	var ray_info : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_info.exclude = [RID(collision_shape_ref)]
	
	ray_info.from = collision_shape_ref.global_transform.origin + Vector3(0,collision_shape_ref.shape.height/2,0)
	ray_info.to = ray_info.from + Vector3(0, 0.2, 0)
	var collision = direct_state.intersect_ray(ray_info)
	if collision:
		head_bonked = true
	else:
		head_bonked = false
	
	if stance == Global.stance.crouching:
		collision_shape_ref.shape.height -= crouch_switch_speed * delta /2
		mesh_ref.transform.origin.y += crouch_switch_speed * delta /1.5
	elif stance == Global.stance.standing and not head_bonked:
		collision_shape_ref.shape.height += crouch_switch_speed * delta /2
		mesh_ref.transform.origin.y -= crouch_switch_speed * delta /1.5
	elif head_bonked:
		pass
	mesh_ref.transform.origin.y = clamp(mesh_ref.transform.origin.y,0.0,0.5)
	collision_shape_ref.shape.height = clamp(collision_shape_ref.shape.height,crouch_height,default_height)


func stair_move():
	var direct_state = character_node.get_world_3d().direct_space_state
	var obs_ray_info : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	obs_ray_info.exclude = [RID(character_node)]
	obs_ray_info.from = mesh_ref.global_transform.origin
	if movement_direction:
		obs_ray_info.to = obs_ray_info.from + Vector3(0, 0, max_close_stair_distance).rotated(Vector3.UP,movement_direction)
	
	#this is used to know if there is obstacle 
	var first_collision = direct_state.intersect_ray(obs_ray_info)
	if first_collision and input_is_moving:
		var climb_ray_info : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		climb_ray_info.exclude = [RID(character_node)]
		climb_ray_info.from = first_collision.collider.global_position + Vector3(0, max_stair_climb_height, 0)
		climb_ray_info.to = first_collision.collider.global_position
		var stair_top_collision = direct_state.intersect_ray(climb_ray_info)
		if stair_top_collision:
			if stair_top_collision.position.y - character_node.global_position.y > 0 and stair_top_collision.position.y - character_node.global_position.y < 0.15:
				movement_state = Global.movement_state.grounded
				is_moving_on_stair = true
				character_node.position.y += stair_top_collision.position.y - character_node.global_position.y
				character_node.global_position += Vector3(0, 0, 0.01).rotated(Vector3.UP,movement_direction)
			else:
				await get_tree().create_timer(0.4).timeout
				is_moving_on_stair = false
		else:
			await get_tree().create_timer(0.4).timeout
			is_moving_on_stair = false
	else:
		await get_tree().create_timer(0.4).timeout
		is_moving_on_stair = false



func smooth_character_rotation(Target:Vector3,nodelerpspeed,delta):
	mesh_ref.rotation.y = lerp_angle(mesh_ref.rotation.y, atan2(Target.x,Target.z) , delta * nodelerpspeed)


func set_bone_x_rotation(skeleton,bone_name, x_rot,CharacterRootNode):
	var bone = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.global_pose_to_local_pose(bone,skeleton.get_bone_global_pose_no_override(bone))
	var rotate_amount = x_rot
	bone_transform = bone_transform.rotated(Vector3(1,0,0), rotate_amount)
	skeleton.set_bone_local_pose_override(bone, bone_transform,1.0,true)
	

var prev :Transform3D 
var current :Transform3D
var anim_speed
func animation_stride_warping(): #this is currently being worked on and tested, so I don't reccomend using it.
	
	
	skeleton_ref.clear_bones_local_pose_override()
	var distance_in_each_frame = (character_node.get_real_velocity()*Vector3(1,0,1)).rotated(Vector3.UP,mesh_ref.transform.basis.get_euler().y).length() 
	var hips = skeleton_ref.find_bone("Hips")
	var hips_transform = skeleton_ref.get_bone_pose(hips)
	var Feet : Array = ["RightFoot","LeftFoot"]
	var Thighs : Array = ["RightUpLeg","LeftUpLeg"]
	
	var hips_distance_to_ground
	var stride_scale : float = 1.0
	for Foot in Feet:
		#Get Bones
		var bone = skeleton_ref.find_bone(Foot)
		var bone_transform = skeleton_ref.get_bone_global_pose_no_override(bone)
		
		var thigh_bone = skeleton_ref.find_bone(Thighs[Feet.find(Foot)])
		var thigh_transform = skeleton_ref.get_bone_global_pose_no_override(thigh_bone)
		var thigh_angle = thigh_transform.basis.get_euler().x
		
		#Calculate
		var stride_direction : Vector3 = Vector3.FORWARD
		var stride_warping_plane_origin = Plane(character_node.get_floor_normal(),bone_transform.origin).intersects_ray(thigh_transform.origin,Vector3.DOWN)
		
		if stride_warping_plane_origin == null:
			return #Failed to get a plane origin/ we are probably in air
		var scale_origin = Plane(stride_direction,stride_warping_plane_origin).project(bone_transform.origin)
		var anim_speed = pow(hips_transform.origin.distance_to(bone_transform.origin),2) - pow(hips_transform.origin.y,2) 
		anim_speed = sqrt(abs(anim_speed))
		stride_scale = clampf(distance_in_each_frame/anim_speed,0.0,2.0)
#		print(stride_scale)
		var foot_warped_location : Vector3 = scale_origin + (bone_transform.origin - scale_origin) * stride_scale
		
		
		# Apply
		
		#test
#		bone_transform.origin = foot_warped_location 
#		skeleton_ref.set_bone_local_pose_override(bone, bone_transform,1.0,true)
		

func calc_grounded_rotation_rate():
	
	if input_is_moving == true:
		match gait:
			Global.gait.walking:
				return lerp(current_movement_data.idle_rotation_rate,current_movement_data.walk_rotation_rate, Global.map_range_clamped((actual_velocity * Vector3(1.0,0.0,1.0)).length(),0.0,current_movement_data.walk_speed,0.0,1.0)) * clamp(aim_rate_h,1.0,3.0)
			Global.gait.running:
				return lerp(current_movement_data.walk_rotation_rate,current_movement_data.run_rotation_rate, Global.map_range_clamped((actual_velocity * Vector3(1.0,0.0,1.0)).length(),current_movement_data.walk_speed,current_movement_data.run_speed,1.0,2.0)) * clamp(aim_rate_h,1.0,3.0)
			Global.gait.sprinting:
				return lerp(current_movement_data.run_rotation_rate,current_movement_data.sprint_rotation_rate,  Global.map_range_clamped((actual_velocity * Vector3(1.0,0.0,1.0)).length(),current_movement_data.run_speed,current_movement_data.sprint_speed,2.0,3.0)) * clamp(aim_rate_h,1.0,2.5)
	else:
		return current_movement_data.idle_rotation_rate * clamp(aim_rate_h,1.0,3.0)



func rotate_in_place_check():
	is_rotating_in_place = false
	if !input_is_moving:
		
		var CameraAngle = Quaternion(Vector3(0,1,0),camera_root.HObject.rotation.y) 
		var MeshAngle = Quaternion(Vector3(0,1,0),mesh_ref.rotation.y) 
		
		rotation_difference_camera_mesh = rad_to_deg(MeshAngle.angle_to(CameraAngle) - PI)
		if (CameraAngle.dot(MeshAngle)) > 0:
			rotation_difference_camera_mesh *= -1
		if floor(abs(rotation_difference_camera_mesh)) > rotation_in_place_min_angle:
			is_rotating_in_place = true
			smooth_character_rotation(-camera_root.HObject.transform.basis.z,calc_grounded_rotation_rate(),get_physics_process_delta_time()) 
	

func ik_look_at(position: Vector3):
	var lookatobject = mesh_ref.get_node("LookAtObject")
	if lookatobject:
		lookatobject.position = position


var PrevVelocity :Vector3
func add_movement_input(direction: Vector3, Speed: float , Acceleration: float) -> void:
	if is_flying == false:
		character_node.velocity.x = lerp(character_node.velocity.x, direction.x * Speed, Acceleration * get_physics_process_delta_time())
		character_node.velocity.z = lerp(character_node.velocity.z, direction.z * Speed, Acceleration * get_physics_process_delta_time())
	else:
		character_node.set_velocity(character_node.get_velocity().lerp(direction * Speed, Acceleration * get_physics_process_delta_time()))
		character_node.move_and_slide()
	input_velocity = Speed * direction
	movement_direction = atan2(input_velocity.x,input_velocity.z)
	input_is_moving = Speed > 0.0
	input_acceleration = Acceleration * direction
	#
	actual_acceleration = (character_node.velocity - PrevVelocity)  / (Acceleration * get_physics_process_delta_time())
	PrevVelocity = character_node.velocity
	#
	actual_velocity = character_node.velocity
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


func calc_animation_data(): # it is used to modify the animation data to get the wanted animation result
	animation_is_moving_backward_relative_to_camera = false if -actual_velocity.rotated(Vector3.UP,-camera_root.HObject.transform.basis.get_euler().y).z >= -0.1 else true
	animation_velocity = actual_velocity
#	a method to make the character' anim walk backward when moving left
#	if is_equal_approx(input_velocity.normalized().rotated(Vector3.UP,-$CameraRoot.HObject.transform.basis.get_euler().y).x,-1.0):
#		animation_velocity = velocity * -1
#		animation_is_moving_backward_relative_to_camera = true
	

func mantle_check():
	pass

func jump() -> void:
	if character_node.is_on_floor() and not head_bonked:
		vertical_velocity = Vector3.UP * jump_magnitude



