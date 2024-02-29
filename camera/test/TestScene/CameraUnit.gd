@tool
extends Node3D

@export var camera:Camera3D
@export var init_distance:float = 10.0:
	get:
		return init_distance
	set(value):
		init_distance=value
		set_camera_distance(init_distance)

@export var init_angle:float=30.0:
	get:
		return init_angle
	set(value):
		init_angle = value
		pitch = init_angle
		init_camera_angle()

@export var look_transform:Node3D
@export var scroll_speed:float=10.0
@export var min_zoom:float = 2.0
@export var max_zoom:float = 30.0
@export var rotate_speed:float = 20.0
@export var threshold:float = 0.01
@export var min_angle:float = -30.0
@export var max_angle:float = 89.0
@export var ray_offset:float = 0.5
@export_flags_3d_physics var ray_mask:int
@export var arm_length:Curve
#鼠标控制模式
var is_free:bool
var is_mouse_control:bool
#鼠标滚动量与偏移量
var scroll_quant:float
var mouse_offset:Vector2
#倾斜度
var pitch:float

#射线检测
var ray:RayCast3D
var ray_distance:float
var zoom_distance:float
var auto_update_zoom:bool=true


signal on_turn_event(float)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_camera_distance(init_distance)
	init_camera_angle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		
		ray_hit()
		
		
		rotate_camera(delta)
		zoom_camera(delta)
		
		
func ray_hit():
	if ray==null:
		ray = RayCast3D.new()
		add_child(ray)
		ray.collision_mask=ray_mask
		ray.collide_with_areas=true
	
	ray.position = position
	ray.target_position = camera.position.normalized()*max_zoom
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var ray_point:Vector3 = ray.get_collision_point()
		ray_distance = abs(ray_point.distance_to(global_position))+ray_offset
	else:
		ray_distance=-1
		
func zoom_camera(delta:float):
	var this_time_scroll:float = get_scroll() * scroll_speed*delta
	var now_distance:float = abs(global_position.distance_to(camera.global_position))
	zoom_distance = lerpf(now_distance,now_distance+this_time_scroll,1-delta)
	#判断一下当前计算的距离与碰撞距离
	zoom_distance = ray_distance if zoom_distance>ray_distance and ray_distance>0.0 else zoom_distance
	
	if auto_update_zoom and ray_distance<0.0 and not is_free and is_mouse_control:
		var armlength:float = get_zoom_by_angle()
		zoom_distance=lerpf(zoom_distance,armlength,delta)
	
	
	set_camera_distance(clampf(zoom_distance,min_zoom,max_zoom))
		
func rotate_camera(delta:float):
	#判断控制模式
	#处理旋转量
	
	var look:Vector2 = mouse_offset * delta * rotate_speed
	#防止抖动
	if look.length_squared()>=threshold and is_mouse_control:
		#处理垂直旋转
		#处理水平旋转
		pitch = clamp_angle(pitch+look.y,min_angle,max_angle)
		if is_free:
			var yaw:float = -rotation_degrees.y
			yaw = clamp_angle(yaw+look.x,-360.0,360.0)
			rotation_degrees = Vector3(-pitch,-yaw,0)
			transform = transform.orthonormalized()
		else:
			#非自由视角，将跟随物体进行旋转
			#记录原始缩放
			#先将跟随物体面向修正为相机面向
			var last_rot:Vector3 = look_transform.global_rotation_degrees
			var last_scale:Vector3 = look_transform.scale
			var yaw:float = clamp_angle(-global_rotation_degrees.y+look.x,-360.0,360.0)
			look_transform.global_rotation_degrees = Vector3(last_rot.x,-yaw,last_rot.z)
			on_turn_event.emit(abs(yaw-last_rot.y))
			look_transform.transform=look_transform.transform.orthonormalized()
			look_transform.scale=last_scale
			rotation_degrees=Vector3(-pitch,0,0)
			transform=transform.orthonormalized()
			
			pass
		
#通过曲线获取角度对应的焦距
func get_zoom_by_angle()->float:
	return arm_length.sample((pitch-min_angle)/(max_angle-min_angle))

func set_camera_distance(distance:float):
	if camera==null:
		printerr("等待设置相机")
		return 
	
	camera.position.z = distance


func init_camera_angle():
	rotation_degrees.x = -init_angle

func get_scroll()->float:
	var res:float = scroll_quant
	scroll_quant=0.0
	return res

func clamp_angle(angle:float,min_angle:float,max_angle:float)->float:
	if angle<-360.0:
		angle += 360.0
	if angle>360.0:
		angle -= 360.0
		
	return clampf(angle,min_angle,max_angle)

#region 修正鼠标偏移量
const min_off:float = -100.0
const max_off:float = 100.0
func normal_axis(axis:Vector2)->Vector2:
	return Vector2(clampf(axis.x,min_off,max_off),clampf(axis.y,min_off,max_off))

#endregion

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			is_free=true
			is_mouse_control=true
		elif event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
			is_free=false
			is_mouse_control=true
		else:
			is_free=false
			is_mouse_control=false
			
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:
			scroll_quant = -event.factor
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
			scroll_quant = event.factor
			
	if event is InputEventMouseMotion:
		mouse_offset = normal_axis(event.relative)
	else:
		mouse_offset = Vector2.ZERO

#region 设置警告
#设置检查警告
func _get_configuration_warnings():
	var msg=[]
	var no_camera:bool=true
	for c in get_children():
		if c is Camera3D:
			no_camera=false
			break
			
	if camera==null or no_camera:
		msg.append("必须设置相机为子节点，且设置相机参数")
		
	if look_transform==null:
		msg.append("必须设置跟随物体参数")
	
	return msg

#endregion
