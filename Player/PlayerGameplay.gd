extends CharacterMovement

#####################################
#Refrences
@onready var CameraRef = $CameraRoot
#####################################

#####################################
#Controls Settings
@export var OnePressJump := false
@export var UsingSprintToggle := false
@export var UsingCrouchToggle := false
#####################################

var h_rotation :float
var v_rotation :float

var direction := Vector3.FORWARD

var PreviousRotationMode 
func _ready():
	super._ready()



func _physics_process(delta):
	super._physics_process(delta)
	Debug()
	
	#------------------ Input Movement ------------------#
	h_rotation = $CameraRoot.HObject.transform.basis.get_euler().y
	v_rotation = $CameraRoot.VObject.transform.basis.get_euler().x

	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),
			v_rotation * (Input.get_action_strength("back") - Input.get_action_strength("forward")) if IsFlying == true else 0.0,
			Input.get_action_strength("back") - Input.get_action_strength("forward"))
		direction = direction.rotated(Vector3.UP,h_rotation).normalized()
		if Gait == Global.Gait.Sprinting :
			AddMovementInput(direction, CurrentMovementData.Sprint_Speed,CurrentMovementData.Sprint_Acceleration)
		elif Gait == Global.Gait.Running:
			AddMovementInput(direction, CurrentMovementData.Run_Speed,CurrentMovementData.Run_Acceleration)
		else:
			AddMovementInput(direction, CurrentMovementData.Walk_Speed,CurrentMovementData.Walk_Acceleration)
	else:
		

		
		AddMovementInput(direction,0,Deacceleration)
		
	
	
		
	if RotationMode == Global.RotationMode.Aiming:
		CameraRoot.Camera.fov = 60.0
	if RotationMode == Global.RotationMode.VelocityDirection or RotationMode == Global.RotationMode.LookingDirection:
		CameraRoot.Camera.fov = 90.0
	
	#------------------ Input Crouch ------------------#
	if UsingCrouchToggle == false:
		if Input.is_action_pressed("crouch"):
			if Stance != Global.Stance.Crouching:
				Stance = Global.Stance.Crouching
		else:
			if Stance != Global.Stance.Standing:
				Stance = Global.Stance.Standing
	else:
		if Input.is_action_just_pressed("crouch"):
			Stance = Global.Stance.Standing if Stance == Global.Stance.Crouching else Global.Stance.Crouching
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if Input.is_action_just_pressed("sprint"):
			if Gait == Global.Gait.Walking:
				Gait = Global.Gait.Running  
			elif Gait == Global.Gait.Running:
				Gait = Global.Gait.Sprinting
			elif Gait == Global.Gait.Sprinting:
				Gait = Global.Gait.Walking
	else:
		if Input.is_action_just_pressed("sprint"):
			if Gait == Global.Gait.Walking:
				Gait = Global.Gait.Running
			elif Gait == Global.Gait.Running:
				Gait = Global.Gait.Sprinting
		if Input.is_action_just_released("sprint"):
			if Gait == Global.Gait.Sprinting or Gait == Global.Gait.Walking:
				Gait = Global.Gait.Walking
			elif Gait == Global.Gait.Running:
				await get_tree().create_timer(0.4).timeout
				if Gait == Global.Gait.Running:
					Gait = Global.Gait.Walking
	#------------------ Input Aim ------------------#
	if Input.is_action_pressed("aim"):
		if RotationMode != Global.RotationMode.Aiming:
			PreviousRotationMode = RotationMode
			RotationMode = Global.RotationMode.Aiming
	else:
		if RotationMode == Global.RotationMode.Aiming:
			RotationMode = PreviousRotationMode
	#------------------ Jump ------------------#
	if is_on_floor():
		if !AnimRef.get("parameters/roll/active"):
			if OnePressJump == true:
				if Input.is_action_just_pressed("jump"):
					if Stance != Global.Stance.Standing:
						Stance = Global.Stance.Standing
					elif not head_bonked:
						jump()
			else:
				if Input.is_action_pressed("jump"):
					if Stance != Global.Stance.Standing:
						Stance = Global.Stance.Standing
					elif not head_bonked:
						jump()
	#------------------ Look At ------------------#
	match RotationMode:
		Global.RotationMode.VelocityDirection:
			if InputIsMoving:
				IKLookAt(motion_velocity + Vector3(0.0,1.0,0.0))
		Global.RotationMode.LookingDirection:
			IKLookAt(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
		Global.RotationMode.Aiming:
			IKLookAt(-$CameraRoot/SpringArm3D.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
	#------------------ Interaction ------------------#
	if Input.is_action_just_pressed("interaction"):
		$CameraRoot/SpringArm3D/Camera/InteractionRaycast.Interact()




var ViewChangedRecently = false
func _input(event):
	#------------------ Change Camera View ------------------#
	if Input.is_action_just_released("SwitchCameraView"):
		if ViewChangedRecently == false:
			ViewChangedRecently = true
			$CameraRoot.ViewAngle = $CameraRoot.ViewAngle + 1 if $CameraRoot.ViewAngle < 2 else 0
			await get_tree().create_timer(0.3).timeout
			ViewChangedRecently = false
		else:
			ViewChangedRecently = false
	if Input.is_action_just_pressed("SwitchCameraView"):
		await get_tree().create_timer(0.2).timeout
		if ViewChangedRecently == false:
			$CameraRoot.ViewMode = $CameraRoot.ViewMode + 1 if $CameraRoot.ViewMode < 1 else 0
			ViewChangedRecently = true

	if event.is_action_pressed("EnableSDFGI"):
		var postprocess = preload("res://Maps/default_env.tres")
		postprocess.sdfgi_enabled = not postprocess.sdfgi_enabled
	if event.is_action_pressed("ragdoll"):
		Ragdoll = true


		if RotationMode == Global.RotationMode.VelocityDirection:
			if CameraRef != null:
				if CameraRef.ViewMode == Global.ViewMode.FirstPerson:
					CameraRef.ViewMode = Global.ViewMode.ThirdPerson
					

func Debug():
	$Status/Label.text = "InputSpeed : %s" % InputVelocity.length()
	$Status/Label2.text = "ActualSpeed : %s" % get_real_velocity().length()
