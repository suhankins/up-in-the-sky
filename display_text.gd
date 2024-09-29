extends Label

const BLANK_CHARACTER = "_"

var text_to_display: String
var timer: SceneTreeTimer
var starting_time: float

@export var typewriter_player: AudioStreamPlayer


func _ready() -> void:
	self.text_to_display = self.text
	self.text = ""


func _process(_delta: float) -> void:
	if not timer:
		return
	var progress = 1.0 - self.timer.time_left / self.starting_time
	var letters_to_display: int = self.text_to_display.length() * progress
	var new_text = text_to_display.left(letters_to_display).replace(BLANK_CHARACTER, "")
	if new_text == text:
		return
	text = new_text
	typewriter_player.play()


func play(time: float) -> void:
	self.starting_time = time
	print_debug("started typing")
	self.timer = get_tree().create_timer(time)
