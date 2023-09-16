extends GameAttribute


@export_category("Energy")
var regenerating_cooldown : bool = false
func enable_normal_cooldown_gen():
	await get_tree().create_timer(cooldown_regen_wait_time_no_exaust).timeout
	if !cooldown_exausted and !being_used:
		regenerating_cooldown = true
func enable_exaust_cooldown_gen():
	await get_tree().create_timer(cooldown_regen_wait_time_exaust).timeout
	if !being_used:
		regenerating_cooldown = true
func regenerate_cooldown(delta):
	if regenerating_cooldown:
		
		current_value = clampf(current_value+(cooldown_regeneration_speed*delta),minimum_value,maximum_value)
		if cooldown_exausted and current_value == maximum_value:
			cooldown_exausted = false
			if cooldown_fill_sound:
				cooldown_fill_sound.play()
			return
		if current_value == maximum_value:
			regenerating_cooldown = false
			if cooldown_fill_sound:
				cooldown_fill_sound.play()
			return


## cooldown regeneration value in each second
@export var cooldown_regeneration_speed : float = 10.0
## cooldown wait time in seconds berfore starting to regenerate
@export var cooldown_regen_wait_time_no_exaust : float = 2.0
## cooldown wait time in case of exausted in seconds berfore starting to regenerate
@export var cooldown_regen_wait_time_exaust : float = 4.0
var cooldown_exausted : bool = false:
	set(value):
		cooldown_exausted = value
		if cooldown_exausted:
			if cooldown_exaust_sound:
				cooldown_exaust_sound.play()

@export_category("Visual Bar")
@export var cooldown_bar : ProgressBar
@export var cooldown_unfill_normal_color : Color
@export var cooldown_unfill_exaust_color : Color

@export_category("Sound Effects")
@export var cooldown_exaust_sound : AudioStreamPlayer3D
@export var cooldown_fill_sound : AudioStreamPlayer3D
var being_used : bool = false
func set_attribute(prev_v, current_v):
	if current_v < prev_v:
		if current_v <= 1.0:
			cooldown_exausted = true
		regenerating_cooldown = false
		if current_v < maximum_value:
			if cooldown_exausted:
				enable_exaust_cooldown_gen()
			else:
				enable_normal_cooldown_gen()
func _process(delta):
	can_use = !cooldown_exausted
	
	regenerate_cooldown(delta)
	if cooldown_bar:
		cooldown_bar.max_value = maximum_value
		cooldown_bar.value = current_value
		cooldown_bar.get_theme_stylebox("background").bg_color = cooldown_unfill_normal_color if !cooldown_exausted else cooldown_unfill_exaust_color
	
