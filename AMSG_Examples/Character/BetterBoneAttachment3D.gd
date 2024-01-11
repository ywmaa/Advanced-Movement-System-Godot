@tool
extends Marker3D
class_name BetterBoneAttachment3D
## This is just a placeholder for BoneAttachment3D from my PR https://github.com/godotengine/godot/pull/82192/

@export var bone_name : String
@export var skeleton : Skeleton3D
var bone_idx : int

enum {BONE_POSE, BONE_POSE_OVERRIDE, BONE_POSE_NO_OVERRIDE, BONE_REST}
@export_enum("BONE_POSE", "BONE_POSE_OVERRIDE", "BONE_POSE_NO_OVERRIDE", "BONE_REST") var bone_pose_mode : int = BONE_POSE

func _ready():
	bone_idx = skeleton.find_bone(bone_name)
	print(bone_idx)


func _process(delta):
	match bone_pose_mode:
		BONE_POSE:
			set_global_transform(skeleton.get_global_transform() * skeleton.get_bone_global_pose(bone_idx))
		BONE_POSE_OVERRIDE:
			set_global_transform(skeleton.get_global_transform() * skeleton.get_bone_global_pose_override(bone_idx))
		BONE_POSE_NO_OVERRIDE:
			set_global_transform(skeleton.get_global_transform() * skeleton.get_bone_global_pose_no_override(bone_idx))
		BONE_REST:
			set_global_transform(skeleton.get_global_transform() * skeleton.get_bone_global_rest(bone_idx))
