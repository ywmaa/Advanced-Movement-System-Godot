extends Node
class_name MotionWarping
 
var ObjectsArray : Array = []
var PositionsArray : Array = []
var NamesArray : Array = []

#We should add the position before starting the animation,
#for example the position of the door that we are interacting with.
#we give it a name to use the same name in the AnimationPlayer
func add_sync_position(position:Vector3, sync_name:String, object):
	PositionsArray.append(position) 
	ObjectsArray.append(object)
	NamesArray.append(sync_name)
	

#remove the position after it is done
func remove_sync_position(sync_name:String):
	var sync_index = NamesArray.find(sync_name)
	PositionsArray.remove_at(sync_index)
	ObjectsArray.remove_at(sync_index)
	NamesArray.remove_at(sync_index)

#this should be called as a method in the animation player, and set the name
#using the name we assigned to the sync position we will tween it, 
#also in the animation player we should specify the time to tween to this required position
func motion_warping(sync_name:String, sync_time:float):
	var sync_index = NamesArray.find(sync_name)
	var position = PositionsArray[sync_index]
	var object = ObjectsArray[sync_index]
	var tween := create_tween()
	tween.tween_property(object, "transform:origin", position, sync_time)
	tween.tween_callback(remove_sync_position.bind(sync_name))
