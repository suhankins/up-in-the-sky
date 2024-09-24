class_name NPCBlackboard extends Blackboard

const DELTA = "delta"
const LAST_PLAYER_POSITION = "last_player_position"
const ALERTED = "alert"
const LIST_OF_NPCS = "list_of_npcs"


func _ready() -> void:
	set_value(DELTA, 1.0)
	set_value(ALERTED, false)
	set_value(LIST_OF_NPCS, [])


func _physics_process(delta: float) -> void:
	set_value(DELTA, delta)
