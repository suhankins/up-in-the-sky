shader_type canvas_item;

uniform float health = 0.5;

void fragment() {
	float alpha = clamp(step(1.0 - health, UV.y) + smoothstep(0.5, 0.0, health), 0.0, 1.0) * texture(TEXTURE, UV).a;
	float redness = 1.0 - step(1.0 - health, UV.y);
	COLOR = vec4(redness, texture(TEXTURE, UV).gb, alpha);
}
