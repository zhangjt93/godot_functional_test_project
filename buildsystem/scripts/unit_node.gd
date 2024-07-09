extends Node3D
class_name UnitNode

@export var mesh:VisualInstance3D
@export var col:StaticBody3D
@export var length:float
@export var width:float

func _ready():
	init_layer(self)

func init_layer(node:Node):
	if node is Slot:
		node.collision_layer = Const.SLOT_LAYER
		node.collision_mask = 0
	elif node is Detect:
		node.collision_layer = Const.DETECT_LAYER
		node.collision_mask = Const.DETECT_LAYER
	elif node is StaticBody3D:
		node.collision_layer = Const.BUILD_LAYER
		node.collision_mask = Const.CHARACTER_LAYER
		
	for c in node.get_children():
		init_layer(c)

func get_aabb()->AABB:
	var aabb = self.mesh.get_aabb()
	aabb *= self.mesh.global_transform.inverse()
	return aabb
