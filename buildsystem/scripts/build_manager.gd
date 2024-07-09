extends Node3D

@export_dir var build_dir:String
@onready var build_node = %BuildSystem
@onready var ghost = %Ghost

signal can_not_build(content:String)

var basics:Array[UnitNode] = []

func set_ghost(node:Node):
	for c in ghost.get_children():
		ghost.remove_child(c)
	ghost.add_child(node)
	
func build(node:BuildUnit,current_position:Vector3,current_rotation:Vector3):
	if not node.ghost.can_build():
		can_not_build.emit('不可创建')
		return 
	if node.type == BuildUnit.UNITTYPE.BASIC:
		var unitnode = await node.build()
		build_node.add_child(unitnode)
		unitnode.global_position = current_position
		unitnode.global_rotation = current_rotation
		basics.append(unitnode)
	else:
		var basic = get_basic_node(node.ghost)
		if basic==null:
			can_not_build.emit("不可创建")
		else:
			var unitnode = await node.build()
			basic.add_child(unitnode)
			unitnode.owner=basic
			unitnode.global_position = current_position
			unitnode.global_rotation = current_rotation

func delete_unit(node:Node):
	if node is UnitNode:
		node.queue_free()

func get_basic_node(node:GhostNode)->UnitNode:
	#通过aabb判断是否在某一个basic中
	var ghost_aabb = node.get_aabb()
	for c in basics:
		var aabb = c.get_aabb()
		if aabb.encloses(ghost_aabb):
			return c
	return null


func _on_save_pressed():
	for i in range(len(basics)):
		var c = basics[i]
		var filename = "%s/%d_BuildNode.tscn"%[build_dir,i]
		var packed_scene = PackedScene.new()
		packed_scene.pack(c)
		var err = ResourceSaver.save(packed_scene,filename)
		if err != OK:
			print("save error to path :",filename)
			return


func _on_load_pressed():
	for c in basics:
		build_node.remove_child(c)
		c.queue_free()
	basics=[]
	
	var dir = DirAccess.open(build_dir)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
			
		if file.ends_with("_BuildNode.tscn"):
			var path = "%s/%s"%[build_dir,file]
			var basic = load(path).instantiate()
			basic.name = file.replace("_BuildNode.tscn","")
			build_node.add_child(basic)
			basics.append(basic)


func _on_delete_pressed():
	for c in basics:
		build_node.remove_child(c)
		c.queue_free()
	basics=[]
