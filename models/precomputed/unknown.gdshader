shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float c = float(float(UV.x - 0.5) * float(UV.y - 0.5) <= 0.0);
	ALBEDO.g = 0.0;
	ALBEDO.rb = vec2(c, c);
}

/*void light() {
	DIFFUSE_LIGHT = vec3(1.0, 1.0, 1.0);
}*/