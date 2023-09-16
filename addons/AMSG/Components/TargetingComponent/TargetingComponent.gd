extends Node
class_name TargetingComponent

@export var detection_raycast : RayCast3D
@export var combat_component : CombatSystem

@export var detectable_object_group : String = "detectable_object" # we can use the node group feature in Godot
@export var detectable_player_group : String = "player" # I am calling any Enemy/AI/Ally a player 


var detected_object : Node3D
var detected_object_combat_component : CombatSystem

var detected_player : Node3D
var detected_player_combat_component : CombatSystem


signal object_detected(object: Node3D, object_combat_component:CombatSystem)
signal enemy_detected(object: Node3D, player_combat_component:CombatSystem)
signal ally_detected(object: Node3D, player_combat_component:CombatSystem)
signal player_detected(object: Node3D, player_combat_component:CombatSystem)
signal detected(object: Node3D) #this activates for all

func _ready():
	detection_raycast.add_exception(get_parent())

func _process(delta):
	if detection_raycast.is_colliding():
		if detected_player == detection_raycast.get_collider() or detected_object == detection_raycast.get_collider():
			return
		
		if detection_raycast.get_collider().is_in_group(detectable_object_group):
			detected_object = detection_raycast.get_collider()
			detected.emit(detected_object)
			
			detected_object_combat_component = detected_object.find_child("CombatSystem")
			if !detected_object_combat_component:
				object_detected.emit(detected_object, null)
				return
			object_detected.emit(detected_object, detected_object_combat_component)
			return
		
		if detection_raycast.get_collider().is_in_group(detectable_player_group):
			detected_player = detection_raycast.get_collider()
			detected.emit(detected_player)
			detected_player_combat_component = detected_player.find_child("CombatSystem")
			if !detected_player_combat_component:
				player_detected.emit(detected_player, null)
				return
			player_detected.emit(detected_player, detected_player_combat_component)
			if detected_player_combat_component.team_id != combat_component.NATURAL_OBJECT and detected_player_combat_component.team_id != combat_component.team_id:
				enemy_detected.emit(detected_player, detected_player_combat_component)
			if detected_player_combat_component.team_id == combat_component.team_id:
				ally_detected.emit(detected_player, detected_player_combat_component)
			return
