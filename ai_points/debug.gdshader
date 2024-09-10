shader_type spatial;

const float WIDTH = 0.05;

void fragment() {
	ALBEDO = vec3(1.0, 0.0, 0.0);
	
	float leftBorderValue = 1.0 - step(WIDTH, UV.x);
	float rightBorderValue = step(1.0 - WIDTH, UV.x);
	float topBorderValue = 1.0 - step(WIDTH, UV.y);
	float bottomBorderValue = step(1.0 - WIDTH, UV.y);
	
	ALPHA = leftBorderValue + rightBorderValue + topBorderValue + bottomBorderValue + 0.05;
}
