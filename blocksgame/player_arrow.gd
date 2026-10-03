extends CharacterBody3D

@export var speed := 14.0
@export var turn_speed := 12.0


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir := Vector3(input.x, 0.0, input.y)
	velocity = dir * speed
	if dir != Vector3.ZERO:
		# El modelo de la flecha apunta hacia -Z (el "frente" en Godot).
		var target := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target, turn_speed * delta)
	move_and_slide()
