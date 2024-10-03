extends CharacterMovementComponent
class_name PlayerGameplayComponent

@export_group("Stamina System", "stamina_")
@export var stamina_use: bool = false
@export var stamina_energy_consumption: float = 15.0#per second
@export var stamina_attribute: GameAttribute

@export var networking : PlayerNetworkingComponent 
@export var targeting_component : TargetingComponent 

func _ready():
	super._ready()
	targeting_component.connect("detected", func(p): print(p))


func _process(delta):
	super._process(delta)
	if gait != Global.gait.sprinting and stamina_use:
		stamina_attribute.being_used = false
	if gait == Global.gait.sprinting and stamina_use:
		if !stamina_attribute.can_use or stamina_attribute.current_value < stamina_energy_consumption*delta:
			gait = Global.gait.running
			return
		stamina_attribute.being_used = true
		stamina_attribute.current_value -= stamina_energy_consumption*delta

func _physics_process(delta):
	super._physics_process(delta)
#	Debug()
	if !networking.is_local_authority():
		if input_is_moving:
			if gait == Global.gait.sprinting:
				add_movement_input(input_direction, current_movement_data.sprint_speed,current_movement_data.sprint_acceleration)
			elif gait == Global.gait.running:
				add_movement_input(input_direction, current_movement_data.run_speed,current_movement_data.run_acceleration)
			else:
				add_movement_input(input_direction, current_movement_data.walk_speed,current_movement_data.walk_acceleration)
		return
	#------------------ Look At ------------------#
	match rotation_mode:
		Global.rotation_mode.velocity_direction:
			if input_is_moving:
				ik_look_at(actual_velocity + Vector3(0.0,1.0,0.0))
		Global.rotation_mode.looking_direction:
			ik_look_at(camera_root.SpringArm.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
		Global.rotation_mode.aiming:
			ik_look_at(camera_root.SpringArm.transform.basis.z * 2.0 + Vector3(0.0,1.5,0.0))
#func Debug():
#	$Status/Label.text = "InputSpeed : %s" % input_velocity.length()
#	$Status/Label2.text = "ActualSpeed : %s" % get_velocity().length()
