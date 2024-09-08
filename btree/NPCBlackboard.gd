class_name NPCBlackboard extends Blackboard

const DELTA = 'delta'
const LAST_PLAYER_POSITION = 'last_player_position'
const ALERTED = 'alert'

func _ready() -> void:
	set_value(DELTA, 1.0)
	set_value(ALERTED, false)

func _physics_process(delta: float) -> void:
	set_value(DELTA, delta)