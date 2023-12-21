extends Node
class_name GameAttribute


@onready var attributes_manager : AttributesManager = get_parent()

@export_category("Attribute")
## Is the attribute name
@export var attribute_name : String
## Is the attribute minimum value
@export var minimum_value : float
## Is the attribute maximum value
@export var maximum_value : float
## Is the attribute initial value
@export var current_value : float : 
	set(v):
		set_attribute(current_value, v)
		current_value = v
var can_use:bool = true


func set_attribute(prev_v, current_v):
	pass

