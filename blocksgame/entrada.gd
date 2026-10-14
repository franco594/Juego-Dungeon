extends Area3D

# Lugar especial del mapa del mundo: marcador verde con nombre. Cuando la flecha
# está encima, aparece el aviso y con "interactuar" (E / Enter / Espacio) se entra.
#
# Uso: arrastrar entrada.tscn al mapa, ponerle nombre y destino en el Inspector.
# Para cambiar el tamaño del área: clic derecho > "Hijos editables" y ajustar la
# CollisionShape3D.

@export var nombre_lugar := "Lugar"
@export_file("*.tscn") var destino := "res://map.tscn"
## Dónde reaparece la flecha al volver, relativo a esta entrada. Tiene que caer
## sobre una calle y fuera del área.
@export var punto_regreso := Vector3(0.0, 0.0, 4.0)
## Altura del marcador verde (por encima del edificio).
@export var altura_marcador := 6.0
## Si es true, se entra apenas la flecha toca el área, sin apretar nada.
@export var entrar_al_tocar := false

@onready var _marcador: Node3D = $Marcador
@onready var _pin: Node3D = $Marcador/Pin
@onready var _nombre: Label3D = $Marcador/Nombre
@onready var _aviso: Label3D = $Aviso

var _jugador: Node3D = null
var _lista := false
var _t := 0.0


func _ready() -> void:
	_nombre.text = nombre_lugar
	_aviso.visible = false
	_marcador.position.y = altura_marcador
	body_entered.connect(_al_entrar_cuerpo)
	body_exited.connect(_al_salir_cuerpo)
	# Si la flecha aparece encima al cargar la escena, no entra sola.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_lista = true


func _process(delta: float) -> void:
	_t += delta
	_marcador.position.y = altura_marcador + sin(_t * 2.5) * 0.3
	_pin.rotation.y += delta * 1.8
	if _jugador and _lista and Input.is_action_just_pressed("interactuar"):
		_entrar()


func _al_entrar_cuerpo(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return
	_jugador = cuerpo
	_aviso.visible = true
	if entrar_al_tocar and _lista:
		_entrar()


func _al_salir_cuerpo(cuerpo: Node3D) -> void:
	if cuerpo == _jugador:
		_jugador = null
		_aviso.visible = false


func _entrar() -> void:
	_jugador = null
	GameState.entrar_a(destino, global_position + punto_regreso)
