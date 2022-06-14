extends Node

var sync_camera_h_transform : Transform3D
var sync_camera_v_transform : Transform3D
var sync_view_mode :  Global.view_mode
var sync_CameraHOffset : float
var sync_position : Vector3:
	set(value):
		sync_position = value
		processed_position = false
var sync_mesh_rotation : Vector3
var sync_direction : Vector3
var sync_input_is_moving : bool
var sync_gait : Global.gait
var sync_rotation_mode : Global.rotation_mode
var sync_stance : Global.stance
var sync_movement_state : Global.movement_state
var sync_movement_action : Global.movement_action
var sync_velocity : Vector3



var processed_position : bool
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(get_parent().name).to_int())

func is_local_authority() -> bool:
	if !multiplayer.has_multiplayer_peer():
		return true
	else:
		return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
