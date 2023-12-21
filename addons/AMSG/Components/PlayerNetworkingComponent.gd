extends Node
class_name PlayerNetworkingComponent
@export var character_movement_component : NodePath
@onready var PlayerRef = get_node(character_movement_component)


var sync_camera_h_transform : Transform3D
var sync_camera_v_transform : Transform3D
var sync_view_mode :  Global.view_mode = Global.view_mode.third_person
var sync_CameraHOffset : float
var sync_position : Vector3:
	set(value):
		sync_position = value
		processed_position = false
var sync_mesh_rotation : Vector3
var sync_direction : Vector3
var sync_input_is_moving : bool
var sync_gait : Global.gait = Global.gait.walking
var sync_rotation_mode : Global.rotation_mode = Global.rotation_mode.velocity_direction
var sync_stance : Global.stance = Global.stance.standing
var sync_movement_state : Global.movement_state = Global.movement_state.grounded
var sync_movement_action : Global.movement_action = Global.movement_action.none
var sync_velocity : Vector3
var processed_position : bool


func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(get_parent().name).to_int())


func is_local_authority() -> bool:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		return true
	else:
		return str(get_parent().name).to_int() == multiplayer.get_unique_id()

#sync player on clients
func _physics_process(_delta):
	if !is_local_authority():
		if not processed_position:
			PlayerRef.character_node.position = sync_position
			processed_position = true
		PlayerRef.mesh_ref.rotation = sync_mesh_rotation
		PlayerRef.input_direction = sync_direction
		PlayerRef.gait = sync_gait
		PlayerRef.stance = sync_stance
		PlayerRef.rotation_mode = sync_rotation_mode 
		PlayerRef.camera_root.VObject.transform = sync_camera_v_transform
		PlayerRef.camera_root.HObject.transform = sync_camera_h_transform
		PlayerRef.camera_root.view_mode = sync_CameraHOffset
		PlayerRef.camera_root.CameraHOffset = sync_CameraHOffset
		PlayerRef.movement_state = sync_movement_state
		PlayerRef.movement_action = sync_movement_action
#		PlayerRef.velocity = sync_velocity
		PlayerRef.input_is_moving = sync_input_is_moving
		return
	
	sync_position = PlayerRef.character_node.position
	sync_mesh_rotation = PlayerRef.mesh_ref.rotation
	sync_direction = PlayerRef.input_direction
	sync_gait = PlayerRef.gait
	sync_stance = PlayerRef.stance
	sync_rotation_mode = PlayerRef.rotation_mode
	sync_camera_h_transform = PlayerRef.camera_root.HObject.transform
	sync_camera_v_transform = PlayerRef.camera_root.VObject.transform
	sync_movement_state = PlayerRef.movement_state
	sync_movement_action = PlayerRef.movement_action
	sync_input_is_moving = PlayerRef.input_is_moving
	sync_view_mode = PlayerRef.camera_root.view_mode
	sync_CameraHOffset = PlayerRef.camera_root.CameraHOffset
