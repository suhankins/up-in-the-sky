class_name NumberAndNode3DTuple

var number: float
var node: Node3D


static var EMPTY = NumberAndNode3DTuple.new(INF, null)


func _init(new_number: float, new_node: Node3D) -> void:
	self.number = new_number
	self.node = new_node
