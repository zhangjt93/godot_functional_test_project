extends Node3D
class_name BuildUnit

signal builded

enum UNITTYPE{
	SELECT,
	BASIC,
	FLOOR,
	WALL,
	CEIL,
	STAIRCASE,
	DELETE
}

@export var type:UNITTYPE
@export_flags_3d_physics var mouse_ray_layer:int:
	get:
		return mouse_ray_layer
	set(value):
		mouse_ray_layer=value
		
@export var icon:CompressedTexture2D:
	get:
		return icon
	set(value):
		icon=value
		
@export var mouse_cursor:CompressedTexture2D:
	get:
		return mouse_cursor
	set(value):
		mouse_cursor=value
		
@export var ghost:GhostNode
@export var unit:PackedScene
@export var ani:AnimationPlayer

func build()->UnitNode:
	ani.play("floor")
	await builded
	var unode = unit.instantiate()
	unode.visible = true
	return unode
	
func preview():
	if self.type!=UNITTYPE.SELECT and self.type!=UNITTYPE.DELETE:
		ghost.visible=true
	
	


func _on_build():
	builded.emit()
	preview()
	
func _on_mid_build():
	ghost.visible=false


func change_mouse_type():
	if self.type==UNITTYPE.DELETE:
		Input.set_custom_mouse_cursor(self.mouse_cursor)
	else:
		Input.set_custom_mouse_cursor(null)
