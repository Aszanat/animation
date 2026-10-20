extends Skeleton3D


class AnimJoint:
	# set automatically
	var cycle_moment: float
	var index: int
	
	# initiators
	var cycle_start_moment: float
	var rotation_zero_angle_offset: float # in radians. Horrible.
	var cycle_angle_range_multiplier: float
	var axis: Vector3
	
	func init(
		cycle_start_moment: float, 
		rotation_zero_angle_offset: float, 
		cycle_angle_range_multiplier: float,
		axis: Vector3):
			self.cycle_start_moment = cycle_start_moment
			self.rotation_zero_angle_offset = rotation_zero_angle_offset
			self.cycle_angle_range_multiplier = cycle_angle_range_multiplier
			self.axis = axis
			return self

var bone_map: Dictionary = {
	"Tail": AnimJoint.new().init(0.5, -2, 0.75, Vector3(1, 0, 0)),
	"Tail.1": AnimJoint.new().init(0.45, 0.5, 0.7, Vector3(1, 0, 0)),
	"Tail.2": AnimJoint.new().init(0.4, 0.5, 0.65, Vector3(1, 0, 0)),
	"Tail.3": AnimJoint.new().init(0.35, 0.5, 0.6, Vector3(1, 0, 0)),
	"Tail.4": AnimJoint.new().init(0.3, 0.5, 0.55, Vector3(1, 0, 0)),

}

var cycle_duration: float = 2 # seconds


func _ready():
	for bone in bone_map:
		print(bone)
		print(bone_map[bone])
		bone_map[bone].cycle_moment = cycle_duration * bone_map[bone].cycle_start_moment
		bone_map[bone].index = self.find_bone(bone)
		var current_rotation: Quaternion = self.get_bone_pose_rotation(bone_map[bone].index)
		self.set_bone_pose_rotation(bone_map[bone].index, current_rotation + Quaternion(bone_map[bone].axis, bone_map[bone].rotation_zero_angle_offset))


func rotate_bone(joint: AnimJoint,delta: float):
	var bone_idx: float = joint.index
	var cycle_moment: float = joint.cycle_moment
	var cycle_angle_range_multiplier: float = joint.cycle_angle_range_multiplier
	var axis: Vector3 = joint.axis
	# cycle_moment is in seconds, runs from 0 to duration
	var current_rotation: Quaternion = self.get_bone_pose_rotation(bone_idx)
	var rotation_angle: float = sin((cycle_moment  / cycle_duration) * TAU) * PI * delta / cycle_duration # in radians
	print(rotation_angle) # you want some better method to calculate this SIMPLY
	# the math will be the same, it's just a matter of easy understanding for this...
	var new_rotation: Quaternion = current_rotation * Quaternion(axis, rotation_angle * cycle_angle_range_multiplier)
	self.set_bone_pose_rotation(bone_idx, new_rotation)
	return


func _physics_process(delta: float):
	for bone in bone_map:
		var cycle_moment = (bone_map[bone].cycle_moment + delta)
		if cycle_moment > cycle_duration:
			cycle_moment = cycle_moment - cycle_duration
		bone_map[bone].cycle_moment = cycle_moment
		rotate_bone(bone_map[bone], delta)
