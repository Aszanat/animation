extends Skeleton3D

class AxisRotation:
	var cycle_start_phase: float # [0, 1)
	var rotation_zero_angle_offset: float # [0, 1) where 1 would be full circle around
	var angle_range: float # [0, 1) technically could be more if the joint is like, SUPER flexible...
	var axis: Vector3
	var angle_calculator: Callable

	func _init(csp: float, rzao: float, ar: float, a: Vector3, ac: Callable) -> void:
		self.cycle_start_phase = csp
		self.rotation_zero_angle_offset = rzao
		self.angle_range = ar
		self.axis = a.normalized()
		self.angle_calculator = ac

class AnimJoint:
	# set automatically
	var index: int # const
	var cycle_phase: float # [0, 1) - changes all the time
	var rotation_zero: Quaternion # const
	var axes: Array[AxisRotation] # const

	func _init(a: Array[AxisRotation]) -> void:
		self.axes = a

var bone_map: Dictionary[String, AnimJoint] = {
	"Tail": AnimJoint.new([AxisRotation.new(0, 0, 0.05, Vector3(1, 0, 0), sin), AxisRotation.new(0.25, 0, 0.05, Vector3(0, 0, 1), sin)]),
	"Tail.1": AnimJoint.new([AxisRotation.new(-0.1, 0, 0.05, Vector3(1, 0, 0), sin), AxisRotation.new(0.15, 0, 0.05, Vector3(0, 0, 1), sin)]),
	"Tail.2": AnimJoint.new([AxisRotation.new(-0.2, 0, 0.05, Vector3(1, 0, 0), sin), AxisRotation.new(0.05, 0, 0.05, Vector3(0, 0, 1), sin)]),
	"Tail.3": AnimJoint.new([AxisRotation.new(-0.3, 0, 0.05, Vector3(1, 0, 0), sin), AxisRotation.new(-0.05, 0, 0.05, Vector3(0, 0, 1), sin)]),
	"Tail.4": AnimJoint.new([AxisRotation.new(-0.4, 0, 0.05, Vector3(1, 0, 0), sin), AxisRotation.new(-0.15, 0, 0.05, Vector3(0, 0, 1), sin)]),
}

var cycle_duration: float = 2 # seconds


func setup_joint(joint: AnimJoint) -> void:
	joint.rotation_zero = self.get_bone_pose_rotation(joint.index)
	joint.cycle_phase = 0

	

func calculate_joint_rotation(joint: AnimJoint) -> Quaternion:
	var new_rotation: Quaternion = joint.rotation_zero
	for axis_rot: AxisRotation in joint.axes:
		var relative_phase: float = joint.cycle_phase + axis_rot.cycle_start_phase
		var angle_offset: float = axis_rot.rotation_zero_angle_offset + axis_rot.angle_calculator.call(relative_phase * TAU)  * axis_rot.angle_range
		var angle_offset_radians: float = angle_offset * TAU
		new_rotation *= Quaternion(axis_rot.axis, angle_offset_radians)
	return new_rotation

func rotate_joint(joint: AnimJoint, delta: float) -> void:
	joint.cycle_phase += delta / cycle_duration
	while joint.cycle_phase >= 1:
		joint.cycle_phase -= 1
	var new_rotation: Quaternion = calculate_joint_rotation(joint)
	self.set_bone_pose_rotation(joint.index, new_rotation)


func _ready()-> void:
	for bone: String in bone_map:
		bone_map[bone].index = self.find_bone(bone)
		setup_joint(bone_map[bone])
		

func _physics_process(delta: float) -> void:
	for bone: String in bone_map:
		rotate_joint(bone_map[bone], delta)
