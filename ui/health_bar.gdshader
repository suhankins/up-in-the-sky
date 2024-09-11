shader_type canvas_item;

uniform float health = 0.5;

void fragment() {
	float alpha = step(1.0 - health, UV.y) * texture(TEXTURE, UV).a;
	float redness = smoothstep(0.5, 0.0, health);
	COLOR = vec4(redness, texture(TEXTURE, UV).gb, alpha);
}
