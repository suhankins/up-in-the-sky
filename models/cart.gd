class_name Cart extends Node3D

@export var covers: Array[Cover]


func enable_cover():
	for cover in covers:
		cover.enabled = true
