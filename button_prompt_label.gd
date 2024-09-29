extends Label

@export var action: StringName


func get_input_event_text(input_event: InputEvent) -> String:
	return input_event.as_text().replace(" (Physical)", "").replace(" - All Devices", "")


func _ready() -> void:
	var keys: String = ""
	for input_event in InputMap.action_get_events(action):
		if keys == "":
			keys = get_input_event_text(input_event)
		else:
			keys = str(keys, " / ", get_input_event_text(input_event))
	self.text = keys
