extends Control
@onready var character_movement_component = $"../CharacterMovementComponent"

@export var camera_root : CameraComponent
@onready var player = get_parent()
@onready var direction = $Control/Direction
@onready var velocity = $Control/Velocity
@onready var mesh = $Control/mesh
@onready var rich_text_label = $RichTextLabel
@onready var rich_text_label_2 = $RichTextLabel2
var debug_text : String = ""
func _physics_process(_delta):
	visible = camera_root.Camera.current
	var h_rot = get_parent().get_node("SpringArm3D").transform.basis.get_euler().y
	var character_node_velocity = player.velocity if player is CharacterBody3D else player.linear_velocity
	$Control.set_rotation(h_rot)
#	direction.rotation = atan2(player.direction.z, player.direction.x) 
	velocity.position = Vector2(character_node_velocity.x, character_node_velocity.z) * 10 
	mesh.rotation = 90-get_node("../Armature").rotation.y - player.rotation.y - .5
	if Input.is_action_just_pressed("show_panel"):
		rich_text_label.visible = !rich_text_label.visible
	debug_text = ""
	debug_text += "3D_Debug_Enabled:[color="+true_false_text_color(DebugDraw3D.debug_enabled)+"]" + str(DebugDraw3D.debug_enabled) +"[/color] "
	debug_text += "Instructions_Visible:[color="+true_false_text_color(rich_text_label.visible)+"]" + str(rich_text_label.visible) +"[/color] "
	debug_text += "Distance_Matching_Enabled:[color="+true_false_text_color(character_movement_component.pose_warping_active)+"]" + str(character_movement_component.pose_warping_active) +"[/color]"
	rich_text_label_2.text = debug_text

func true_false_text_color(state:bool) -> String:
	return "green" if state else "red"
