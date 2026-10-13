extends CharacterBody3D

## Control en tercera persona para recorrer la ciudad. La cámara puede orbitar
## con el mouse; el movimiento siempre se calcula respecto de la cámara.

@export var walk_speed := 4.2
@export var run_speed := 7.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.0025
@export var turn_speed := 10.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: Node3D = $Visual

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotation.x = clampf(
			camera_pivot.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-35.0), deg_to_rad(25.0)
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity

	var input_vector := _movement_input()
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	var direction := (right.normalized() * input_vector.x - forward.normalized() * input_vector.y).normalized()
	var current_speed := run_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if direction.length_squared() > 0.001:
		var target_yaw := atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, turn_speed * delta)

	move_and_slide()


func _movement_input() -> Vector2:
	var value := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		value.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		value.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		value.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		value.y += 1.0
	return value.normalized()
