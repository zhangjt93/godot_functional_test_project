extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_node = %CameraNode
const min_angle = 25.0
const max_angle = 85.0

var rotate_offset:Vector2
var pitch:float = 15


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	self.collision_layer = Const.CHARACTER_LAYER
	self.collision_mask = Const.ENV_LAYER | Const.BUILD_LAYER
	
func clamp_angle(angle:float,min_angle:float,max_angle:float)->float:
	if angle<-360.0:
		angle += 360.0
	if angle>360.0:
		angle -= 360.0
	return clampf(angle,min_angle,max_angle)
	
func _process(delta):
	rotate_offset *= delta
	if rotate_offset.length_squared()>=0.01:
		pitch = clamp_angle(pitch+rotate_offset.y,min_angle,max_angle)
		var last_rot = global_rotation_degrees
		var last_scale = scale
		var yaw = clamp_angle(-camera_node.global_rotation_degrees.y+rotate_offset.x,-360.0,360.0)
		global_rotation_degrees = Vector3(last_rot.x,-yaw,last_rot.z)
		transform = transform.orthonormalized()
		scale = last_scale
		camera_node.rotation_degrees = Vector3(-pitch,0,0)
		camera_node.transform = camera_node.transform.orthonormalized()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func turn_camera(vec2:Vector2):
	self.rotate_offset = vec2
