extends Node3D

# Los items de Blocks1.tres no traen colisión (salvo "01_Cube"), así que la
# generamos al iniciar a partir de la malla de cada bloque colocado en el GridMap.

@onready var grid_map: GridMap = $GridMap
@onready var exit_area: Area3D = $Salida


func _ready() -> void:
	_build_collisions()
	exit_area.body_entered.connect(_on_exit_entered)


# Atajo de respaldo: la tecla Q vuelve a la ciudad desde cualquier punto.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode == KEY_Q:
		GameState.return_to_overworld()


func _on_exit_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameState.return_to_overworld()


func _build_collisions() -> void:
	var lib := grid_map.mesh_library
	if lib == null:
		return

	var body := StaticBody3D.new()
	body.name = "GridMapCollision"
	grid_map.add_child(body)

	var shape_cache := {}
	for cell in grid_map.get_used_cells():
		var item := grid_map.get_cell_item(cell)
		if not shape_cache.has(item):
			var mesh := lib.get_item_mesh(item)
			shape_cache[item] = mesh.create_trimesh_shape() if mesh else null
		var shape: Shape3D = shape_cache[item]
		if shape == null:
			continue

		var cs := CollisionShape3D.new()
		cs.shape = shape
		cs.transform = Transform3D(
			grid_map.get_cell_item_basis(cell),
			grid_map.map_to_local(cell)
		) * lib.get_item_mesh_transform(item)
		body.add_child(cs)
