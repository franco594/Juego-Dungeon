extends Node3D

# Dungeon en primera persona. Las colisiones las genera el GridMap solo, a partir
# de la MeshLibrary (House.tres ya trae una forma por item).

@onready var exit_area: Area3D = $Salida


func _ready() -> void:
	exit_area.body_entered.connect(_on_exit_entered)


# Atajo de respaldo: Q ("volver_mundo") vuelve a la ciudad desde cualquier punto.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("volver_mundo"):
		GameState.volver_al_mundo()


func _on_exit_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		GameState.volver_al_mundo()
