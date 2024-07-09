extends Node3D
class_name GhostNode

@export var mesh:VisualInstance3D
@export var length:float
@export var width:float
@export var detection:Detect

func _ready():
	init_layer(self)

func get_aabb()->AABB:
	var aabb = self.mesh.get_aabb()
	#这里aabb相对坐标的点，转全局坐标
	aabb *= self.mesh.global_transform.inverse()
	return aabb

func init_layer(node:Node):
	if node is Detect:
		node.collision_layer=Const.DETECT_LAYER
		node.collision_mask=Const.DETECT_LAYER
		
	for c in node.get_children():
		init_layer(c)
		
func can_build()->bool:
	if detection!=null:
		for area in detection.get_overlapping_areas():
			if area is Detect:
				return false
	return true
