extends CharacterBody3D

# Flecha del mapa del mundo (estilo SMT III).
# Se mueve libremente, sin casillas, pero solo sobre las celdas del GridMap que son
# calles. Pintar o borrar calles en el GridMap cambia por dónde puede andar, sin tocar
# código.

@export var velocidad := 9.0
@export var velocidad_correr := 15.0
@export var velocidad_giro := 12.0
## Medio ancho de la flecha: cuánto lugar necesita para pasar entre edificios.
@export var radio := 0.7
## Altura a la que flota la flecha (las calles miden 0.5 de alto).
@export var altura := 0.7
@export var grid_map: GridMap
## Nombres de los items de la MeshLibrary por los que se puede caminar.
@export var calles: PackedStringArray = ["Road02", "Road03", "Road04", "Road05", "Road06", "Road07"]

@onready var _modelo: Node3D = $Modelo

var _items_calle := {}
var _t := 0.0


func _ready() -> void:
	add_to_group("jugador")
	global_position.y = altura
	if grid_map and grid_map.mesh_library:
		for id in grid_map.mesh_library.get_item_list():
			if grid_map.mesh_library.get_item_name(id) in calles:
				_items_calle[id] = true
	if _items_calle.is_empty():
		push_warning("La flecha no encontró calles: se mueve sin restricciones.")


func _physics_process(delta: float) -> void:
	var entrada := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	var dir := Vector3(entrada.x, 0.0, entrada.y)
	var rapidez := velocidad_correr if Input.is_action_pressed("correr") else velocidad
	if dir != Vector3.ZERO:
		global_position = _mover(global_position, dir * rapidez * delta)
		# El modelo apunta hacia -Z (el "frente" en Godot).
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), velocidad_giro * delta)

	# Pulso suave, como el cursor del mapa en SMT.
	_t += delta
	var s := 1.0 + sin(_t * 5.0) * 0.06
	_modelo.scale = Vector3(s, 1.0, s)


# Intenta el paso completo; si choca, desliza por un solo eje. Si la flecha va
# derecho contra una esquina pero hay calle adelante, la centra para que entre.
func _mover(pos: Vector3, paso: Vector3) -> Vector3:
	if _libre(pos + paso):
		return pos + paso
	var nueva := pos
	var movio := false
	if paso.x != 0.0 and _libre(nueva + Vector3(paso.x, 0.0, 0.0)):
		nueva.x += paso.x
		movio = true
	if paso.z != 0.0 and _libre(nueva + Vector3(0.0, 0.0, paso.z)):
		nueva.z += paso.z
		movio = true
	if movio:
		return nueva

	# Asistencia de esquinas: alinear con la calle que está adelante.
	var rapidez := paso.length()
	if absf(paso.x) >= absf(paso.z):
		var adelante := pos + Vector3(signf(paso.x) * (radio + 0.2), 0.0, 0.0)
		if _es_calle(adelante):
			var objetivo := _centro_celda(adelante).z
			nueva.z = move_toward(pos.z, objetivo, rapidez)
	else:
		var adelante := pos + Vector3(0.0, 0.0, signf(paso.z) * (radio + 0.2))
		if _es_calle(adelante):
			var objetivo := _centro_celda(adelante).x
			nueva.x = move_toward(pos.x, objetivo, rapidez)
	return nueva if _libre(nueva) else pos


# La flecha entra si sus cuatro esquinas están sobre calle.
func _libre(p: Vector3) -> bool:
	return _es_calle(p + Vector3(radio, 0.0, radio)) \
		and _es_calle(p + Vector3(-radio, 0.0, radio)) \
		and _es_calle(p + Vector3(radio, 0.0, -radio)) \
		and _es_calle(p + Vector3(-radio, 0.0, -radio))


func _celda(p: Vector3) -> Vector3i:
	var c := grid_map.local_to_map(grid_map.to_local(Vector3(p.x, 0.1, p.z)))
	return Vector3i(c.x, 0, c.z)


func _es_calle(p: Vector3) -> bool:
	if _items_calle.is_empty():
		return true
	return _items_calle.has(grid_map.get_cell_item(_celda(p)))


func _centro_celda(p: Vector3) -> Vector3:
	return grid_map.to_global(grid_map.map_to_local(_celda(p)))
