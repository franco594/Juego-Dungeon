extends Area3D

# Entrada a un lugar especial. Cambia a la escena del dungeon al tocarla.

@export_file("*.tscn") var dungeon_scene: String = "res://map.tscn"
# Dónde reaparece la flecha al volver (relativo a esta entrada). Debe quedar
# fuera del Area3D, si no volvería a entrar al dungeon al instante.
@export var exit_offset := Vector3(0.0, -0.5, -2.5)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameState.enter_dungeon(dungeon_scene, global_position + exit_offset)
