shader_type spatial;

uniform sampler2D NegXTexture: filter_nearest;
uniform vec2 NegXUVstart = vec2(0, 0);
uniform vec2 NegXUVsize = vec2(1, 1);
uniform sampler2D PosXTexture: filter_nearest;
uniform vec2 PosXUVstart = vec2(0, 0);
uniform vec2 PosXUVsize = vec2(1, 1);
uniform sampler2D NegYTexture: filter_nearest;
uniform vec2 NegYUVstart = vec2(0, 0);
uniform vec2 NegYUVsize = vec2(1, 1);
uniform sampler2D PosYTexture: filter_nearest;
uniform vec2 PosYUVstart = vec2(0, 0);
uniform vec2 PosYUVsize = vec2(1, 1);
uniform sampler2D NegZTexture: filter_nearest;
uniform vec2 NegZUVstart = vec2(0, 0);
uniform vec2 NegZUVsize = vec2(1, 1);
uniform sampler2D PosZTexture: filter_nearest;
uniform vec2 PosZUVstart = vec2(0, 0);
uniform vec2 PosZUVsize = vec2(1, 1);

uniform float PosXEnabled = 0.;
uniform float PosYEnabled = 0.;
uniform float PosZEnabled = 0.;
uniform float NegXEnabled = 0.;
uniform float NegYEnabled = 0.;
uniform float NegZEnabled = 0.;

void fragment() {
	vec2 uvPos = floor(UV * vec2(3, 2));
	vec2 uv = fract(UV * vec2(3, 2));
	switch (int(uvPos.x)){
		case 0:
			switch (int(uvPos.y)){
				case 0: //PosZ
					vec4 c = texture(PosZTexture, uv * PosZUVsize + PosZUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * PosZEnabled;
					break;
				case 1: //NegX
					vec4 c = texture(NegXTexture, uv * NegXUVsize + NegXUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * NegXEnabled;
					break;
			} break;
		case 1:
			switch (int(uvPos.y)){
				case 0: //PosX
					vec4 c = texture(PosXTexture, uv * PosXUVsize + PosXUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * PosXEnabled;
					break;
				case 1: //PosY
					vec4 c = texture(PosYTexture, uv * PosYUVsize + PosYUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * PosYEnabled;
					break;
			} break;
		case 2:
			switch (int(uvPos.y)){
				case 0: //NegZ
					vec4 c = texture(NegZTexture, uv * NegZUVsize + NegZUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * NegZEnabled;
					break;
				case 1: //NegY
					vec4 c = texture(NegYTexture, uv * NegYUVsize + NegYUVstart);
					ALBEDO.rgb = c.rgb;
					ALPHA = c.a * NegYEnabled;
					break;
			} break;
	}
}
