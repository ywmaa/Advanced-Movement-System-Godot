extends Node
class_name CombatSystem


enum {NATURAL_OBJECT=0}
var team_id : int = 0

@export var attribute_map : AttributesManager

var last_attacker_id : int

@rpc("any_peer","reliable")
func damage(dmg:float,attacker_player_peer_id:int,impact_point:Vector3=Vector3.ZERO, impact_force:float=0.0, impact_bone_name:String=""):
	last_attacker_id = attacker_player_peer_id
	
	var health = attribute_map.attributes["health"].current_value
	if dmg > health and health > 25.0:
		attribute_map.attributes["health"].current_value = 1.0
	else:
		attribute_map.attributes["health"].current_value -= dmg
#		print("player : " + str(multiplayer.get_unique_id()) + " health : " + str(health))
