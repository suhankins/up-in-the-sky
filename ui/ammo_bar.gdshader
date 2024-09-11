shader_type canvas_item;

uniform float ammo = 0.0;

void fragment() {
	float redness = 1.0 - step(0.01, ammo);
	COLOR = vec4(redness - 0.5, texture(TEXTURE, UV).gba);
}
