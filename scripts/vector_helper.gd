class_name VectorHelper

static func get_with_y(vector: Vector3, y: float = 0) -> Vector3:
    return Vector3(vector.x, y, vector.z)

static func vector_angle(vector: Vector3) -> float:
    return vector.signed_angle_to(Vector3(0, 0, -1), Vector3(0, -1, 0))

static func get_direction(from: Vector3, to: Vector3) -> Vector3:
    return VectorHelper.get_with_y(to - from).normalized()