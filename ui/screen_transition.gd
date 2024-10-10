class_name ScreenTransition extends TextureRect

signal fade_finished


func fade_in():
	var tween = self.create_tween()
	self.anchor_top = 0
	self.anchor_bottom = 0
	tween.tween_property(self, "anchor_bottom", 1, 1).set_trans(Tween.TRANS_SINE)
	await tween.finished
	fade_finished.emit()


func fade_out():
	var tween = self.create_tween()
	self.anchor_top = 0
	self.anchor_bottom = 1
	tween.tween_property(self, "anchor_top", 1, 1).set_trans(Tween.TRANS_SINE)
	await tween.finished
	fade_finished.emit()
