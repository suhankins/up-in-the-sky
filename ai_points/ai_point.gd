class_name AIPoint extends Node3D

var occupied_by: EnemyNPC = null


func _process(_delta: float) -> void:
	occupied_by = null


func occupy(actor: EnemyNPC) -> bool:
	if self.occupied_by == null or self.occupied_by == actor:
		self.occupied_by = actor
		return true
	return false
