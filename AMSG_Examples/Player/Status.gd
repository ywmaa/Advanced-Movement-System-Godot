extends Control

@onready var player = get_parent()
@onready var direction = $Control/Direction
@onready var velocity = $Control/Velocity
@onready var mesh = $Control/mesh

func _physics_process(_delta):
	
	var h_rot = get_parent().get_node("SpringArm3D").transform.basis.get_euler().y
	
	$Control.set_rotation(h_rot)
#	direction.rotation = atan2(player.direction.z, player.direction.x) 
	velocity.position = Vector2(player.velocity.x, player.velocity.z) * 10 
	mesh.rotation = 90-get_node("../Armature").rotation.y - player.rotation.y - .5
