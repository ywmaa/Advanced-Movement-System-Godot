extends Node
class_name MotionWarping

var position_objects_array : Array = []
var rotation_objects_array : Array = []
var positions_array : Array = []
var rotations_array : Array = []
var names_array : Array = []

#We should add the position before starting the animation,
#for example the position of the door that we are interacting with.
#we give it a name to use the same name in the AnimationPlayer
func add_sync_position(position:Vector3, rotation:Vector3, sync_name:String, position_object,rotation_object):
	positions_array.append(position) 
	rotations_array.append(rotation) 
	position_objects_array.append(position_object)
	rotation_objects_array.append(rotation_object)
	names_array.append(sync_name)
	

#remove the position after it is done
func remove_sync_position(sync_name:String):
	var sync_index = names_array.find(sync_name)
	positions_array.remove_at(sync_index)
	rotations_array.remove_at(sync_index)
	position_objects_array.remove_at(sync_index)
	rotation_objects_array.remove_at(sync_index)
	names_array.remove_at(sync_index)

## this should be called as a method in the animation player, and set the name
## using the name we assigned to the sync position that we will tween it, 
## also in the animation player we should specify the time to tween to this required position
func motion_warping(sync_name:String, sync_time:float):

	var sync_index = names_array.find(sync_name)
	var position = positions_array[sync_index]
	var rotation = rotations_array[sync_index]
	var position_object = position_objects_array[sync_index]
	var rotation_object = rotation_objects_array[sync_index]
	var tween := create_tween()
	var rotation_tween := create_tween()
	tween.tween_property(position_object, "transform:origin", position, sync_time)
	rotation_tween.tween_property(rotation_object, "rotation", rotation, sync_time)
	tween.tween_callback(remove_sync_position.bind(sync_name))
