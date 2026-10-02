extends Node3D

# Los items de Blocks1.tres no traen colisión (salvo "01_Cube"), así que la
# generamos al iniciar a partir de la malla de cada bloque colocado en el GridMap.

@onready var grid_map: GridMap = $GridMap


func _ready() -> void:
	_build_collisions()


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
