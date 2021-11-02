extends RayCast3D

var current_collider

@onready var interaction_label = get_node("../../../../Status/InteractionLabel")

func _ready():
	interaction_label.set_text("")

func _process(delta):
	var collider = get_collider()
	
	if is_colliding() and collider is Interactable:
		if current_collider != collider:
			set_interaction_text(collider.get_interaction_text())
			current_collider = collider
		
		if Input.is_action_just_pressed("interaction"):
			collider.interact()
			set_interaction_text(collider.get_interaction_text())
	elif current_collider:
		current_collider = null
		set_interaction_text("")


func set_interaction_text(text):
	if text == "":
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_keycode_string(InputMap.action_get_events("interaction")[0].keycode)
		interaction_label.set_text("Press %s to %s" % [interaction_key , text])
		interaction_label.set_visible(true)
