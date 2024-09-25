class_name NPCBlackboard extends Blackboard

const DELTA = "delta"
const LAST_PLAYER_POSITION = "last_player_position"
const ALERTED = "alert"
const LIST_OF_NPCS = "list_of_npcs"

const TEAM_VALUES = [LAST_PLAYER_POSITION, ALERTED, LIST_OF_NPCS]


func _ready() -> void:
	set_value(DELTA, 1.0)


func _physics_process(delta: float) -> void:
	set_value(DELTA, delta)


func set_value(key: Variant, value: Variant, blackboard_name: String = DEFAULT) -> void:
	assert(
		blackboard_name != DEFAULT or not TEAM_VALUES.has(key),
		str("Key ", key, " can only be used with a non-default blackboard")
	)
	super.set_value(key, value, blackboard_name)


func get_value(
	key: Variant, default_value: Variant = null, blackboard_name: String = DEFAULT
) -> Variant:
	assert(
		blackboard_name != DEFAULT or not TEAM_VALUES.has(key),
		str("Key ", key, " can only be used with a non-default blackboard")
	)
	return super.get_value(key, default_value, blackboard_name)
