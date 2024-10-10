shader_type spatial;

void fragment() {
	ALPHA = (1.0 - smoothstep(0.0, 0.3, abs(1.0 - 0.5 - UV.x))) - (1.0 - smoothstep(0.0, 0.1, UV.y)) - smoothstep(0.6, 1.0, UV.y);
	ALBEDO = vec3(1.0, 0.0, 0.0);
}
