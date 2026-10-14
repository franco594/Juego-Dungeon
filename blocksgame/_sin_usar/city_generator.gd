extends Node3D

# Genera una ciudad de prueba al iniciar: manzanas con edificios de distinta altura,
# calles y avenidas, parques y un edificio especial con la entrada al primer dungeon.
# Los parámetros se ajustan desde el Inspector.

@export var seed_value := 2026
@export var blocks := Vector2i(6, 6)
@export var block_size := 30.0
@export var street_width := 8.0
@export var avenue_every := 3
@export var avenue_extra := 6.0
@export var lots_per_side := 4
@export var min_height := 4.0
@export var max_height := 26.0
@export var park_chance := 0.12
@export var special_block := Vector2i(3, 2)
@export_file("*.tscn") var dungeon_scene := "res://map.tscn"

var _span := Vector2.ZERO
var _palette: Array[Color] = [
	Color(0.72, 0.70, 0.66),
	Color(0.62, 0.66, 0.74),
	Color(0.78, 0.78, 0.80),
	Color(0.55, 0.58, 0.64),
	Color(0.80, 0.72, 0.62),
]


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var xs := _axis_starts(blocks.x)
	var zs := _axis_starts(blocks.y)
	_span = Vector2(_axis_span(blocks.x), _axis_span(blocks.y))
	var half_diag := _span.length() * 0.5

	var transforms: Array[Transform3D] = []
	var colors: Array[Color] = []

	_build_ground()
	_build_boundary()

	for ix in blocks.x:
		for iz in blocks.y:
			var center := Vector3(xs[ix] + block_size * 0.5, 0.0, zs[iz] + block_size * 0.5)
			if Vector2i(ix, iz) == special_block:
				_add_pad(transforms, colors, center, Color(0.46, 0.47, 0.50), 0.15)
				_add_building(transforms, colors, center,
					Vector2(block_size * 0.7, block_size * 0.7), 14.0, Color(0.75, 0.28, 0.25))
				_add_block_collision(center)
				_add_entrance(Vector3(center.x, 1.0, center.z + block_size * 0.5 + 1.0))
			elif rng.randf() < park_chance:
				_add_pad(transforms, colors, center, Color(0.25, 0.45, 0.27), 0.1)
			else:
				_add_pad(transforms, colors, center, Color(0.46, 0.47, 0.50), 0.15)
				_fill_block(rng, transforms, colors, center, half_diag)
				_add_block_collision(center)

	_build_multimesh(transforms, colors)


# --- Distribución -----------------------------------------------------------

func _street_width(k: int) -> float:
	return street_width + (avenue_extra if k % avenue_every == 0 else 0.0)


func _axis_span(n: int) -> float:
	var total := n * block_size
	for k in n + 1:
		total += _street_width(k)
	return total


# Inicio de cada manzana a lo largo de un eje, con la ciudad centrada en el origen.
func _axis_starts(n: int) -> Array[float]:
	var starts: Array[float] = []
	var pos := -_axis_span(n) * 0.5
	for i in n:
		pos += _street_width(i)
		starts.append(pos)
		pos += block_size
	return starts


func _fill_block(rng: RandomNumberGenerator, transforms: Array[Transform3D],
		colors: Array[Color], center: Vector3, half_diag: float) -> void:
	var lot := block_size / lots_per_side
	# Más cerca del centro de la ciudad, edificios más altos.
	var downtown := 1.0 - clampf(Vector2(center.x, center.z).length() / half_diag, 0.0, 1.0)
	for i in lots_per_side:
		for j in lots_per_side:
			var lot_center := Vector3(
				center.x - block_size * 0.5 + lot * (i + 0.5),
				0.0,
				center.z - block_size * 0.5 + lot * (j + 0.5))
			var foot := Vector2(lot, lot) - Vector2(
				rng.randf_range(0.6, 1.6), rng.randf_range(0.6, 1.6))
			var h := lerpf(min_height, max_height,
				pow(rng.randf(), 2.2) * (0.3 + 0.7 * downtown))
			var base := _palette[rng.randi() % _palette.size()]
			var b := rng.randf_range(0.88, 1.05)
			_add_building(transforms, colors, lot_center, foot, h,
				Color(base.r * b, base.g * b, base.b * b))


# --- Visual -----------------------------------------------------------------

func _add_building(transforms: Array[Transform3D], colors: Array[Color],
		pos: Vector3, footprint: Vector2, height: float, color: Color) -> void:
	transforms.append(Transform3D(
		Basis.from_scale(Vector3(footprint.x, height, footprint.y)),
		Vector3(pos.x, height * 0.5, pos.z)))
	colors.append(color)


func _add_pad(transforms: Array[Transform3D], colors: Array[Color],
		center: Vector3, color: Color, height: float) -> void:
	var s := block_size + 1.6
	transforms.append(Transform3D(
		Basis.from_scale(Vector3(s, height, s)),
		Vector3(center.x, height * 0.5, center.z)))
	colors.append(color)


func _build_multimesh(transforms: Array[Transform3D], colors: Array[Color]) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.95
	mesh.material = mat

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, colors[i])

	var inst := MultiMeshInstance3D.new()
	inst.multimesh = mm
	add_child(inst)


func _build_ground() -> void:
	var body := StaticBody3D.new()
	body.position = Vector3(0.0, -0.5, 0.0)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(_span.x, 1.0, _span.y)
	cs.shape = shape
	body.add_child(cs)

	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.20, 0.21, 0.24)
	mat.roughness = 1.0
	mesh.material = mat
	mi.mesh = mesh
	body.add_child(mi)
	add_child(body)


# --- Colisiones -------------------------------------------------------------

# Una sola caja por manzana: las calles quedan libres y es barato para la física.
func _add_block_collision(center: Vector3) -> void:
	_add_solid(Vector3(center.x, 20.0, center.z), Vector3(block_size, 40.0, block_size))


func _build_boundary() -> void:
	var t := 2.0
	var h := 10.0
	_add_solid(Vector3(0.0, h * 0.5, -(_span.y + t) * 0.5), Vector3(_span.x + 2.0 * t, h, t))
	_add_solid(Vector3(0.0, h * 0.5, (_span.y + t) * 0.5), Vector3(_span.x + 2.0 * t, h, t))
	_add_solid(Vector3(-(_span.x + t) * 0.5, h * 0.5, 0.0), Vector3(t, h, _span.y))
	_add_solid(Vector3((_span.x + t) * 0.5, h * 0.5, 0.0), Vector3(t, h, _span.y))


func _add_solid(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)


# --- Entrada al dungeon -----------------------------------------------------

func _add_entrance(pos: Vector3) -> void:
	var area := Area3D.new()
	area.set_script(load("res://entrance.gd"))
	area.set("dungeon_scene", dungeon_scene)
	# La entrada mira hacia +Z: al volver, la flecha reaparece unos metros más adelante.
	area.set("exit_offset", Vector3(0.0, -0.5, 3.0))
	area.position = pos

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.0, 2.0, 2.0)
	cs.shape = shape
	area.add_child(cs)

	# Marca amarilla en el piso.
	var marker := MeshInstance3D.new()
	var marker_mesh := BoxMesh.new()
	marker_mesh.size = Vector3(4.0, 0.05, 2.0)
	var marker_mat := StandardMaterial3D.new()
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker_mat.albedo_color = Color(1.0, 0.85, 0.2)
	marker_mesh.material = marker_mat
	marker.mesh = marker_mesh
	marker.position = Vector3(0.0, -0.8, 0.0)
	area.add_child(marker)

	# Pin verde flotante, visible incluso detrás de edificios.
	var pin := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.9
	cone.bottom_radius = 0.0
	cone.height = 2.2
	var pin_mat := StandardMaterial3D.new()
	pin_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pin_mat.albedo_color = Color(0.2, 0.9, 0.35)
	pin_mat.no_depth_test = true
	cone.material = pin_mat
	pin.mesh = cone
	pin.position = Vector3(0.0, 7.0, 0.0)
	area.add_child(pin)

	add_child(area)
