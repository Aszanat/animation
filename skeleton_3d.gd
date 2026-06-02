extends Skeleton3D

var cycle_duration: float = 2 # seconds
var cycle_moment: float


func _ready():
    cycle_moment = 0

func rotate_bone(bone_idx: int, delta: float, axis: Vector3 = Vector3(1, 0, 0)):
    # cycle_moment is in seconds, runs from 0 to duration
    var current_rotation: Quaternion = self.get_bone_pose_rotation(bone_idx)
    var rotation_angle: float = sin((cycle_moment / cycle_duration) * TAU) * PI * delta / cycle_duration # in radians
    print(rotation_angle)
    var new_rotation: Quaternion = current_rotation * Quaternion(axis, rotation_angle)
    self.set_bone_pose_rotation(bone_idx, new_rotation)
    return


func _physics_process(delta: float):
    var tail_idx: int = self.find_bone("Tail")
    cycle_moment = (cycle_moment + delta)
    if cycle_moment > cycle_duration:
        cycle_moment = cycle_moment - cycle_duration
    rotate_bone(tail_idx, delta)
    # rotate_bone(0, delta, Vector3(1, 0, 0))
