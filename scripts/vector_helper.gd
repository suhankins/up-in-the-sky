class_name VectorHelper

static func get_with_y(vector: Vector3, y: float = 0) -> Vector3:
    return Vector3(vector.x, y, vector.z)

static func vector_angle(vector: Vector3) -> float:
    return vector.signed_angle_to(Vector3(0, 0, -1), Vector3(0, -1, 0))
