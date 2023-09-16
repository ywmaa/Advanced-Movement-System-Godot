extends GameAttribute
class_name PausedAttribute

@export_category("Pause Text")
@export var pause_label : Label

func set_attribute(prev_v, current_v):
	if !attributes_manager:
		return
	if pause_label:
		pause_label.set_visible(current_v > 0);
	else:
		print_debug("No print_label assigned")

func _process(delta):
	pass
