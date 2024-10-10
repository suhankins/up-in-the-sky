extends Sprite3D


func _on_timer_timeout():
	self.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	self.visible = false
