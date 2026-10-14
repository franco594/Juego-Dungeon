extends Camera3D

# Cámara del mapa del mundo: ángulo fijo e inclinado (estilo SMT III) que sigue al
# objetivo manteniendo siempre el mismo desplazamiento.

@export var objetivo: Node3D
## Desde dónde mira, relativo al objetivo. Más Y = más cenital; más Z = más inclinada.
@export var desplazamiento := Vector3(0.0, 22.0, 13.0)
@export var suavizado := 6.0

var _ubicada := false


func _ready() -> void:
	_ubicar()


func _process(delta: float) -> void:
	if objetivo == null:
		return
	if not _ubicada:
		_ubicar()
		return
	var meta := objetivo.global_position + desplazamiento
	global_position = global_position.lerp(meta, clampf(suavizado * delta, 0.0, 1.0))


# Se coloca directo (sin deslizarse) y fija la orientación una sola vez.
func _ubicar() -> void:
	if objetivo == null:
		return
	look_at_from_position(objetivo.global_position + desplazamiento, objetivo.global_position)
	_ubicada = true
