class_name NPCBlackboard extends Blackboard

func _ready() -> void:
	set_value("delta", 1.0)

func _physics_process(delta: float) -> void:
	set_value("delta", delta)