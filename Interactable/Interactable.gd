extends Node
class_name Interactable

func get_interaction_text():
	return "Interact"
	

func interact():
	print("Interacted with %s" % name)

