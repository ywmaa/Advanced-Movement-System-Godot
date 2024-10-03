extends Node
class_name AttributesManager


@export var character : Node
var attributes : Dictionary

func _ready():
	for child in get_children():
		if !(child is GameAttribute):
			assert("Only GameAttribute childs are allowed")
		attributes[child.attribute_name] = child
