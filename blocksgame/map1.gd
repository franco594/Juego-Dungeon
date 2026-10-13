extends Node3D

## Escena de ciudad (overworld): crea colisiones para las piezas del GridMap y
## usa el área "Salida" como entrada al dungeon.

@export_file("*.tscn") var dungeon_scene := "res://map.tscn"
@export var position_after_return := Vector3(0.0, 1.0, 4.0)

@onready var grid_map: GridMap = $GridMap
@onready var portal: Area3D = $Salida
@onready var player: CharacterBody3D = $CharacterBody3D


func _ready() -> void:
	_build_collisions()
	portal.body_entered.connect(_on_portal_body_entered)
	if GameState.has_return_position:
		player.global_position = GameState.return_position
		GameState.has_return_position = false


func _on_portal_body_entered(body: Node3D) -> void:
	if body == player:
		GameState.enter_dungeon(dungeon_scene, portal.global_position + position_after_return)


func _build_collisions() -> void:
	var library := grid_map.mesh_library
	if library == null:
		push_warning("El GridMap del overworld no tiene MeshLibrary asignada.")
		return

	var body := StaticBody3D.new()
	body.name = "GridMapCollision"
	grid_map.add_child(body)
	var shape_cache: Dictionary = {}

	for cell in grid_map.get_used_cells():
		var item := grid_map.get_cell_item(cell)
		if not shape_cache.has(item):
			var mesh := library.get_item_mesh(item)
			shape_cache[item] = mesh.create_trimesh_shape() if mesh else null
		var shape: Shape3D = shape_cache[item]
		if shape == null:
			continue
		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.transform = Transform3D(
			grid_map.get_cell_item_basis(cell), grid_map.map_to_local(cell)
		) * library.get_item_mesh_transform(item)
		body.add_child(collision)
