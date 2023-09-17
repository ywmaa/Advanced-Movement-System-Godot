extends Node
class_name PlayerController

#####################################
#Controls Settings
@export var OnePressJump := false
@export var UsingSprintToggle := false
@export var UsingCrouchToggle := false
#####################################

@export var character_component : PlayerGameplayComponent 
@export var networking : PlayerNetworkingComponent 

var controls_the_possessed_character:bool=false
var peer_id:int
var inputs :int
var input_vector :Vector2
var h_rotation :float
#var v_rotation :float
var previous_rotation_mode 
var direction := Vector3.ZERO

#####################################
#Locks System
@export var lock_system : LockSystem
#####################################

@export var mouse_sensitivity : float = 0.01




func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	possess_character(character_component,true)



func possess_character(p_character_component:CharacterMovementComponent,control:bool):
	if character_component:
		character_component.camera_root.Camera.current = false
	controls_the_possessed_character = control
	character_component = p_character_component
	character_component.camera_root.Camera.current = networking.is_local_authority()


func _physics_process(delta):
	if !networking.is_local_authority():
		return
	
	if lock_system != null && lock_system.is_locked:
		direction = Vector3.ZERO
		character_component.add_movement_input()
		return
	
	#------------------ Input Movement ------------------#
	h_rotation = character_component.camera_root.HObject.transform.basis.get_euler().y
	var v_rotation = character_component.camera_root.VObject.transform.basis.get_euler().x
	
	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),
			remap(v_rotation,-PI/2,PI/2,-1.0,1.0) if character_component.is_flying == true else 0.0,
			Input.get_action_strength("back") - Input.get_action_strength("forward"))
		direction = direction.rotated(Vector3.UP,h_rotation).normalized()
		if character_component.gait == Global.gait.sprinting :
			character_component.add_movement_input(direction, character_component.current_movement_data.sprint_speed,character_component.current_movement_data.sprint_acceleration)
		elif character_component.gait == Global.gait.running:
			character_component.add_movement_input(direction, character_component.current_movement_data.run_speed,character_component.current_movement_data.run_acceleration)
		else:
			character_component.add_movement_input(direction, character_component.current_movement_data.walk_speed,character_component.current_movement_data.walk_acceleration)
	else:
		direction = Vector3.ZERO
		character_component.add_movement_input()
		
	
	#------------------ Input Crouch ------------------#
	if UsingCrouchToggle == false:
		if Input.is_action_pressed("crouch"):
			if character_component.stance != Global.stance.crouching:
				character_component.stance = Global.stance.crouching
		else:
			if character_component.stance != Global.stance.standing:
				character_component.stance = Global.stance.standing
	else:
		if Input.is_action_just_pressed("crouch"):
			character_component.stance = Global.stance.standing if character_component.stance == Global.stance.crouching else Global.stance.crouching
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if Input.is_action_just_pressed("sprint"):
			if character_component.gait == Global.gait.walking:
				character_component.gait = Global.gait.running  
			elif character_component.gait == Global.gait.running:
				character_component.gait = Global.gait.sprinting
			elif character_component.gait == Global.gait.sprinting:
				character_component.gait = Global.gait.walking
	else:
		if Input.is_action_just_pressed("sprint"):
			if character_component.gait == Global.gait.walking:
				character_component.gait = Global.gait.running
			elif character_component.gait == Global.gait.running:
				character_component.gait = Global.gait.sprinting
		if Input.is_action_just_released("sprint"):
			if character_component.gait == Global.gait.sprinting or character_component.gait == Global.gait.walking:
				character_component.gait = Global.gait.walking
			elif character_component.gait == Global.gait.running:
				await get_tree().create_timer(0.4).timeout
				if character_component.gait == Global.gait.running:
					character_component.gait = Global.gait.walking
	#------------------ Input Aim ------------------#
	if Input.is_action_pressed("aim"):
		if character_component.rotation_mode != Global.rotation_mode.aiming:
			previous_rotation_mode = character_component.rotation_mode
			character_component.rotation_mode = Global.rotation_mode.aiming
	else:
		if character_component.rotation_mode == Global.rotation_mode.aiming:
			character_component.rotation_mode = previous_rotation_mode
	#------------------ Jump ------------------#=
	if OnePressJump == true:
		if Input.is_action_just_pressed("jump"):
			if character_component.stance != Global.stance.standing:
				character_component.stance = Global.stance.standing
			else:
				character_component.jump()
	else:
		if Input.is_action_pressed("jump"):
			if character_component.stance != Global.stance.standing:
				character_component.stance = Global.stance.standing
			else:
				character_component.jump()

	#------------------ Interaction ------------------#
	if Input.is_action_just_pressed("interaction"):
		character_component.camera_root.Camera.get_node("InteractionRaycast").Interact()




var view_changed_recently = false
func _input(event):
	if event is InputEventMouseMotion:
		if !character_component or !controls_the_possessed_character:
			return
		character_component.camera_root.camera_h += -event.relative.x * mouse_sensitivity
		character_component.camera_root.camera_v += -event.relative.y * mouse_sensitivity
	#------------------ Motion Warping test------------------#
	if event.is_action_pressed("fire"):
		character_component.anim_ref.active = false
		get_node("../MotionWarping").add_sync_position(Vector3(4.762,1.574,-1.709),Vector3(0,PI,0),"kick_target",self,character_component.mesh_ref)
		get_node("../AnimationPlayer").play("Kick")
		await get_tree().create_timer(2.6).timeout
		character_component.anim_ref.active = true
		
	#------------------ Change Camera View ------------------#
	if Input.is_action_just_released("switch_camera_view"):
		if view_changed_recently == false:
			view_changed_recently = true
			character_component.camera_root.view_angle = character_component.camera_root.view_angle + 1 if character_component.camera_root.view_angle < 2 else 0
			await get_tree().create_timer(0.3).timeout
			view_changed_recently = false
		else:
			view_changed_recently = false
	if Input.is_action_just_pressed("switch_camera_view"):
		await get_tree().create_timer(0.2).timeout
		if view_changed_recently == false:
			character_component.camera_root.view_mode = character_component.camera_root.view_mode + 1 if character_component.camera_root.view_mode < 1 else 0
			view_changed_recently = true
	if networking.is_local_authority():
		if event.is_action_pressed("EnableSDFGI"):
			var postprocess = preload("res://AMSG_Examples/Maps/default_env.tres")
			postprocess.sdfgi_enabled = not postprocess.sdfgi_enabled
			postprocess.ssil_enabled = not postprocess.ssil_enabled
			postprocess.ssao_enabled = not postprocess.ssao_enabled
			postprocess.ssr_enabled = not postprocess.ssr_enabled
			postprocess.glow_enabled = not postprocess.glow_enabled
	if event.is_action_pressed("ragdoll"):
		character_component.ragdoll = true


		if character_component.rotation_mode == Global.rotation_mode.velocity_direction:
			if character_component.camera_root != null:
				if character_component.camera_root.view_mode == Global.view_mode.first_person:
					character_component.camera_root.view_mode = Global.view_mode.third_person
					
	if(Input.is_action_pressed("pause")):
		if(lock_system.contains_lock("pauseGame")):
			lock_system.remove_lock("pauseGame")
		else:
			lock_system.add_lock("pauseGame")
