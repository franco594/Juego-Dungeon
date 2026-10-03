extends Camera3D

# Cámara con ángulo fijo que sigue al objetivo manteniendo siempre el mismo offset.

@export var target: Node3D
@export var offset := Vector3(0.0, 25.0, 14.4)
@export var smoothing := 8.0

var _snapped := false


func _process(delta: float) -> void:
	if target == null:
		return
	var goal := target.global_position + offset
	if not _snapped:
		# Primer cuadro: se coloca directo, sin deslizarse desde otra posición.
		global_position = goal
		_snapped = true
		return
	global_position = global_position.lerp(goal, clampf(smoothing * delta, 0.0, 1.0))
