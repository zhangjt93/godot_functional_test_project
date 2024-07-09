extends Node3D
class_name MainScene

@export var units_scenes:Array[PackedScene]

@onready var loglabel = %LogLabel
@onready var units={}
@onready var items=%Items
@onready var buildmanager = %BuildManager
@onready var delete_but = %DeleteButton
@onready var world_ui = %WorldUI
@onready var label3d = %Label3D
@onready var uiani = %UIAni
@onready var character = %Character

var env_collision_mask:int=0
var current_unit:BuildUnit
var is_building:bool=false
var current_position:Vector3
var current_rotation:Vector3
var mouse_in_world:bool=true
var selected_unit:UnitNode
var is_turn_camera:bool = false

enum STATUS{
	OK,
	ERR
}

class Result:
	extends RefCounted
	
	var status:STATUS:
		get:
			return status
		set(value):
			status=value
	
	var position:Vector3:
		get:
			return position
		set(value):
			position=value
			
	static func SUCCESS(position:Vector3):
		var res = Result.new()
		res.status=STATUS.OK
		res.position=position
		return res
	
	static func ERROR():
		var res = Result.new()
		res.status=STATUS.ERR
		return res

# Called when the node enters the scene tree for the first time.
func _ready():
	for index in range(len(units_scenes)):
		var unit = units_scenes[index].instantiate()
		if unit is BuildUnit:
			units[index] = unit
		
	for id in units.keys():
		var item = BuildItem.new(id,units[id].icon)
		items.add_child(item)
		item.mouse_filter=Control.MOUSE_FILTER_PASS
		item.item_selected.connect(Callable(self,"_on_item_selected"))
	
	current_unit=units[0]
	env_collision_mask = current_unit.mouse_ray_layer
	buildmanager.set_ghost(current_unit)
	current_unit.change_mouse_type()
func _on_item_selected(id:int):
	
	if current_unit.ani!=null and current_unit.ani.is_playing():
		await current_unit.builded
		

	current_unit=units[id]
	env_collision_mask = current_unit.mouse_ray_layer
	buildmanager.set_ghost(current_unit)
	if current_unit.type !=BuildUnit.UNITTYPE.SELECT:
		current_unit.preview()
	current_unit.change_mouse_type()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_in_world and not is_building:
		var node = _get_mouse_position_on_obj(Const.SLOT_LAYER)
		if node and node['collider'] is Slot:
			loglabel.text="x:%f\ny:%f\nz:%f"%[node['collider'].position.x,node['collider'].position.y,node['collider'].position.z]
			current_unit.global_position=node['collider'].global_position
			current_unit.global_rotation=node['collider'].global_rotation
			current_position=node['collider'].global_position
			current_rotation=node['collider'].global_rotation
		else:
			var res = _get_mouse_position_in_world()
			if res.status==STATUS.OK:
				loglabel.text="x:%f\ny:%f\nz:%f"%[res.position.x,res.position.y,res.position.z]
				current_unit.global_position=res.position
				current_unit.global_rotation = Vector3.ZERO
				current_position=res.position
				current_rotation = Vector3.ZERO
			else:
				loglabel.text="未获取到世界坐标"


func _get_mouse_position_in_world()->Result:
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos)*1000
	var space_status = get_world_3d().direct_space_state
	var intersection = space_status.intersect_ray(PhysicsRayQueryParameters3D.create(from,to,env_collision_mask))
	
	if intersection:
		return Result.SUCCESS(intersection.position)
	else:
		return Result.ERROR()


func _on_panel_container_mouse_entered():
	loglabel.text="未获取到世界坐标"
	mouse_in_world=false
	 # Replace with function body.


func _on_panel_container_mouse_exited():
	mouse_in_world=true # Replace with function body.

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and mouse_in_world:
			if delete_but.visible:
				close_delete_but()
			if event.button_index == MOUSE_BUTTON_LEFT: 
				if current_unit.type!=BuildUnit.UNITTYPE.SELECT and current_unit.type!=BuildUnit.UNITTYPE.DELETE:
					var node = _get_mouse_position_on_obj(Const.SLOT_LAYER)
					if current_unit.type==BuildUnit.UNITTYPE.BASIC or (node and node['collider'] is Slot):
						is_building=true
						await buildmanager.build(current_unit,current_position,current_rotation)
						is_building=false
					else:
						_on_build_manager_can_not_build('不可创建')
				elif  current_unit.type==BuildUnit.UNITTYPE.DELETE:
					var node = _get_mouse_position_on_obj(Const.BUILD_LAYER)
					if node:
						buildmanager.delete_unit(node['collider'].get_parent())
			elif event.button_index==MOUSE_BUTTON_RIGHT:
				is_turn_camera=true
				var node = _get_mouse_position_on_obj(Const.BUILD_LAYER)
				if node:
					selected_unit = node['collider'].get_parent()
					show_delete_but()
				else:
					if delete_but.visible:
						close_delete_but()
			else:
				is_turn_camera = false
		else:
			is_turn_camera = false
			
	if event is InputEventMouseMotion and is_turn_camera:
		character.turn_camera((event as InputEventMouseMotion).velocity)
	else:
		character.turn_camera(Vector2.ZERO)
		

func show_delete_but():
	delete_but.visible = true
	var mouse_pos = get_viewport().get_mouse_position()
	delete_but.position=mouse_pos

func _get_mouse_position_on_obj(collision_mask:int=2):
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos)*1000
	var space_status = get_world_3d().direct_space_state
	return space_status.intersect_ray(PhysicsRayQueryParameters3D.create(from,to,collision_mask))
	


func _on_delete_button_pressed():
	#删除建筑
	buildmanager.delete_unit(selected_unit)
	close_delete_but()
	
func close_delete_but():
	selected_unit=null
	delete_but.release_focus()
	delete_but.visible=false

func _on_ui_ani_end():
	label3d.visible=false


func _on_build_manager_can_not_build(content):
	uiani.advance(0)
	world_ui.position=current_position
	label3d.text=content
	label3d.visible=true
	uiani.play("ui_ani")
