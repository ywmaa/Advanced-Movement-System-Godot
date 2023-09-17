extends Node
class_name LockSystem

#The array of locks that are presently applied. The player can perform an action if this array is empty.
#The locks can be used for any manner of things: player movement in cutscenes, restricting dialogue choices, door open conditions etc
var _locks = []

var lock_count : int :
	get:
		return _locks.size()

#An event to hook into - primarily for debugging.
signal Lock_Added(lockName:String)
signal Lock_Removed(lockName:String)

#This one should only emit if is_locked would have changed.
signal Lock_Status_Changed(newStatus:bool)	

#A getter to see if any locks are being applied
@export var is_locked : bool :
	get:
		return _check_is_locked()

#If a lock called lock_name hasn't already been added, adds one.
func add_lock(lock_name:String):
	#Don't add duplicate locks
	if(contains_lock(lock_name)):
		print_debug("Lock %lock is already added." % lock_name)
		return
	else:
		#Add locks and emit events
		_locks.append(lock_name)
		emit_signal("Lock_Added", lock_name)
		#if this is the first and only lock, the locked status has changed to true
		if(_locks.size() == 1):
			Lock_Status_Changed.emit(true)
		return;
		
#Removes a lock with the name lock_name. Prints a message if it's not in there.
func remove_lock(lock_name:String):
	if(contains_lock(lock_name)):
		_locks.erase(lock_name)
		#If there's now zero locks remaining, emit event
		if(_locks.size() == 0):
			Lock_Status_Changed.emit(false)
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

#Prints all current locks - useful for tracking down issues when locks haven't been lifted
func debug_locks():
	var log = "Printing all locks"
	for lock in _locks:
		print_debug("\n" + str(lock))

#To be used for debug - for when the locks need to be bypassed to test.
func debug_release_all_locks():
	for lock in _locks:
		Lock_Removed.emit(lock)
	_locks.clear();
