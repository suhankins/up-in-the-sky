shader_type spatial;
render_mode unshaded;

uniform float progress = 0.0;

const float SIZE = 0.2;

void fragment() {
	float alphaValue = 1.0 - smoothstep(0.0, SIZE, abs(1.0 - progress - UV.y));
	
	ALBEDO = vec3(1.0);
	ALPHA = alphaValue + 0.01;
}
