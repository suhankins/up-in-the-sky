extends Node
## For cases when thing isn't support on the web, or tanks performance


func _ready() -> void:
	if OS.get_name() == "Web":
		self.queue_free()
