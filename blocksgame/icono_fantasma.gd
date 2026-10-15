extends Node3D

# Si algo tapa al ícono (un edificio, por ejemplo), se sigue viendo a través
# como una silueta translúcida. Donde nada lo tapa, se ve el ícono normal.
# Va en el nodo "Modelo" de la flecha: agrega un "fantasma" a cada malla que
# encuentre dentro, sin tocar el modelo original.

## Opacidad del fantasma cuando está tapado (0 = invisible, 1 = opaco).
@export_range(0.0, 1.0) var alfa_oculto := 0.45
## Margen en metros para no confundir al ícono con tapado por sí mismo.
@export var tolerancia := 0.08

const SHADER_CODE := """
shader_type spatial;
// Se dibuja sin test de profundidad, pero el propio shader descarta las partes
// que NO están tapadas. Solo caras frontales: las traseras de la esfera
// quedarían "detrás" del ícono y se confundirían con una oclusión.
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_back, blend_mix;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float ghost_alpha : hint_range(0.0, 1.0) = 0.45;
uniform float bias = 0.08;
uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 c = texture(albedo_tex, UV) * tint;
	float depth = texture(depth_tex, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float scene_z = -view.z;   // distancia a lo más cercano ya dibujado
	float frag_z = -VERTEX.z;  // distancia de este punto del ícono
	float tapado = step(scene_z + bias, frag_z);
	ALBEDO = c.rgb;
	ALPHA = ghost_alpha * tapado;
}
"""

var _shader: Shader


func _ready() -> void:
	_shader = Shader.new()
	_shader.code = SHADER_CODE
	for malla in find_children("*", "MeshInstance3D", true, false):
		_agregar_fantasma(malla as MeshInstance3D)


func _agregar_fantasma(origen: MeshInstance3D) -> void:
	if origen.mesh == null:
		return
	var fantasma := MeshInstance3D.new()
	fantasma.name = "Fantasma"
	fantasma.mesh = origen.mesh
	fantasma.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	origen.add_child(fantasma)

	for i in origen.mesh.get_surface_count():
		var mat := ShaderMaterial.new()
		mat.shader = _shader
		mat.set_shader_parameter("ghost_alpha", alfa_oculto)
		mat.set_shader_parameter("bias", tolerancia)
		# Copia la textura y el color del material original del modelo.
		var base := origen.get_active_material(i) as BaseMaterial3D
		if base:
			mat.set_shader_parameter("tint", base.albedo_color)
			if base.albedo_texture:
				mat.set_shader_parameter("albedo_tex", base.albedo_texture)
		fantasma.set_surface_override_material(i, mat)
