extends GameAttribute




@export_category("Visual Bar")
@export var health_bar : ProgressBar


func set_attribute(prev_v, current_v):
	if !attributes_manager:
		return
	if current_v <= 0.0: # and not dead
		pass #death
	


func _process(delta):
	if health_bar:
		health_bar.max_value = maximum_value
		health_bar.value = current_value
