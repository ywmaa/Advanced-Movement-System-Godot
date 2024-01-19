@tool
extends Node3D
class_name MantleComponent
@export var character_collision_shape : CollisionShape3D
@export var character_node : PhysicsBody3D
@export var animation_tree : AnimationTree
@export var mantle_anim : String = "Mantle"
#@export var character_height : float = 1.75
@onready var ledge_top_detect : RayCast3D = $LedgeTopDetect
@onready var ledge_detect : RayCast3D = $LedgeDetect
@onready var shape_cast_3d = $ShapeCast3D
@onready var ledge_ground_detect = $LedgeGroundDetect

var is_climbing : bool

func _get_configuration_warnings():
	if not get_parent() is Skeleton3D:
		return ["Parent Must be Skeleton3D."]

func _ready():
	if not get_parent() is Skeleton3D:
		assert(false, "Parent Must be Skeleton3D.")
		update_configuration_warnings()
	if not character_node is CharacterBody3D and not character_node is RigidBody3D:
		assert(false, "Character Node Must be either CharacterBody3D or RigidBody3D, please choose the right node from the inspector.")
	shape_cast_3d.shape = character_collision_shape.shape
	#shape_cast_3d.position = character_collision_shape.position
	shape_cast_3d.add_exception(character_node)
	ledge_top_detect.add_exception(character_node)
	ledge_detect.add_exception(character_node)
	ledge_ground_detect.add_exception(character_node)
func _physics_process(delta):
	ledge_detect.position.y = shape_cast_3d.shape.height#character_height
	ledge_top_detect.position.y = shape_cast_3d.shape.height + 0.25#character_height + 0.25
	ledge_ground_detect.position.y = ledge_top_detect.position.y
	ledge_ground_detect.position.z = 1
	ledge_detect.rotation_degrees.x = -90
	ledge_top_detect.rotation_degrees.x = -90
func detect_ledge():
	if is_climbing:
		return
	if ledge_detect.is_colliding() and ledge_ground_detect.is_colliding() and !ledge_top_detect.is_colliding():
		shape_cast_3d.global_position = shape_cast_3d.shape.height/2*Vector3.UP + Vector3(0,0.1,0) + ledge_ground_detect.get_collision_point()
		if !shape_cast_3d.is_colliding(): #The character can fit into the mantle location, Climb
			mantle()
			
			
func mantle():
	is_climbing = true
	if character_node is RigidBody3D:
		character_node.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	if character_node is CharacterBody3D:
		character_node.velocity = Vector3.ZERO
		character_node.move_and_slide()
	animation_tree.active = false
	
	var anim_player : AnimationPlayer = get_node(String(animation_tree.get_path()) + "/" + String(animation_tree.anim_player))
	anim_player.connect("animation_finished", func(anim):\
		character_node.global_position = shape_cast_3d.global_position;\
		animation_tree.active = true;\
		await get_tree().create_timer(0.1).timeout;\
		is_climbing = false
	)
	anim_player.play(mantle_anim)
	
