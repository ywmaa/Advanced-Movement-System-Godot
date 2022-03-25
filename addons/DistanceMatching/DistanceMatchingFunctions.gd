extends Node
class_name distance_matching


#For Predicting Stop Location
static func CalculateStopLocation(CurrentCharacterLocation:Vector3,Velocity:Vector3,Acceleration:Vector3,delta):
	#I didn't write the whole algorithm myself, but I changed some stuff so it works with Godot Engine and removed stuff I think isn't usefull , you can find it here https://answers.unrealengine.com/questions/531204/predict-stop-position-of-character-ahead-in-time.html

	# Small number break loop when velocity is less than this value
	var SmallVelocity = 0.0

	# Current velocity at current frame in unit/frame
	var CurrentVelocityInFrame = Velocity * delta

	# Store velocity direction for later use
	var CurrentVelocityDirection = (Velocity*Vector3(1.0,0.0,1.0)).normalized() 

	# Current deacceleration at current frame in unit/frame^1.5
	var CurrentDeaccelerationInFrame = Acceleration.length() * pow(delta,1.5)

	# Calculate number of frames needed to reach zero velocity and gets its int value
	var StopFrameCount = CurrentVelocityInFrame.length() / CurrentDeaccelerationInFrame

	# float variable use to store distance to targeted stop location
	var StoppingDistance := 0.0

	#Do Stop calculation go through all frames and calculate stop distance in each frame and stack them
	
	for i in StopFrameCount:
		#Update velocity
		CurrentVelocityInFrame.lerp(Vector3.ZERO,CurrentDeaccelerationInFrame) 
		
		# Calculate distance travel in current frame and add to previous distance
		StoppingDistance += (CurrentVelocityInFrame*Vector3(1.0,0.0,1.0)).length() 
		
		#if velocity in XY plane is small break loop for safety
		if ((CurrentVelocityInFrame*Vector3(1.0,0.0,1.0)).length() <= SmallVelocity):
			break


	# return stopping distance from player position in previous frame

	
	#get_tree().get_root().get_node("Node/StopLocation").transform.origin = transform.origin + CurrentVelocityDirection * StoppingDistance + Vector3(0.0,0.75,0.0) #For Debug
	return CurrentCharacterLocation * delta + CurrentVelocityDirection * StoppingDistance

