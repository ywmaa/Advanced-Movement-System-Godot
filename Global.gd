extends Node


#------------------ Player Enums ------------------#
enum Gait {Walking , Running , Sprinting}
enum MovementState {None , Grounded , In_Air , Mantling, Ragdoll}
enum MovementAction {None ,LowMantle , HighMantle , Rolling , GettingUp}
enum OverlayState {Default , Rifle , Pistol}
enum RotationMode {VelocityDirection , LookingDirection , Aiming}
enum Stance {Standing , Crouching}
enum ViewMode {ThirdPerson , FirstPerson}
enum MantleType {HighMantle , LowMantle, FallingCatch}
enum MovementDirection {Forward , Right, Left, Backward}


func MapRangeClamped(value,InputMin,InputMax,OutputMin,OutputMax):
	value = clamp(value,InputMin,InputMax)
	return ((value - InputMin) / (InputMax - InputMin) * (OutputMax - OutputMin) + OutputMin)
