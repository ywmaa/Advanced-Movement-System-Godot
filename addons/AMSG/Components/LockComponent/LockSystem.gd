extends Node
class_name LockSystem

#The array of locks that are presently applied. The player can perform an action if this array is empty.
#The locks can be used for any manner of things: player movement in cutscenes, restricting dialogue choices, door open conditions etc
var _locks = []

#An event to hook into - primarily for debugging.
signal Lock_Added(lockName:String)

#A getter to see if any locks are being applied
@export var is_locked : bool :
	get:
		return _check_is_locked()

#If a lock called lock_name hasn't already been added, adds one.
func add_lock(lock_name:String):
	if(contains_lock(lock_name)):
		print_debug("Lock %lock is already added." % lock_name)
		return
	else:
		_locks.append(lock_name)
		emit_signal("Lock_Added", lock_name)
		return;
		
#Removes a lock with the name lock_name. Prints a message if it's not in there.
func remove_lock(lock_name:String):
	if(contains_lock(lock_name)):
		_locks.erase(lock_name)
	else:
		print_debug("Lock %lock cannot be removed as it isn't there." % lock_name)

#Returns true if _locks has any entries added, false if no locks are being applied
func _check_is_locked():
	return _locks.size() > 0;

#Returns true if a lock called lock_name is already added to _locks
func contains_lock(lock_name:String):
	for lock in _locks:
		if lock == lock_name:
			return true;
	return false;
