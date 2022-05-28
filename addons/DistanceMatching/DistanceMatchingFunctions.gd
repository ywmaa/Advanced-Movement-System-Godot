extends Node
class_name distance_matching


#For Predicting Stop Location
static func CalculateStopLocation(CurrentCharacterLocation:Vector3,Velocity:Vector3,deacceleration:Vector3,delta):
	return CurrentCharacterLocation + (Velocity * CalculateStopTime(Velocity,deacceleration) * delta * 8)

static func CalculateStopTime(Velocity:Vector3,deacceleration:Vector3):
	var time = Velocity.length() / deacceleration.length()
	return time
