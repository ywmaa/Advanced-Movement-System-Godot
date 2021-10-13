extends Interactable

@export var light : NodePath
@onready var light_node = get_node(light)
@export var on : bool :
	get: return on
	set(state):
		on = state
		if light_node != null:
			set_light_energy()
@export var energy_when_on = 1
@export var energy_when_off = 0

func _ready():
	on = on #just initialize

func interact():
	on = !on

func get_interaction_text():
	return "Switch Light Off" if on else "Switch Light On" 
	
func set_light_energy():
	light_node.set_param(Light3D.PARAM_ENERGY,energy_when_on if on else energy_when_off)
