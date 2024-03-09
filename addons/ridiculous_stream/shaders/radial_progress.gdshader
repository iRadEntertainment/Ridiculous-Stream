shader_type canvas_item;

uniform sampler2D fill_texture_overlay;
uniform sampler2D bg_texture;
uniform float fill_ratio:hint_range(0., 1.) = 1.;
uniform float start_angle:hint_range(0., 360.) = 0.;
uniform float max_angle:hint_range(0., 360.) = 360.;
uniform bool invert_fill = false;
uniform bool reflect_x = false;
uniform bool reflect_y = false;
uniform vec2 offset = vec2(0., 0.);

mat2 tex_rotate(float _angle){
	return mat2(vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)));
}

void fragment() {
	float fill_angle = radians(fill_ratio * max_angle);
	vec2 uv = ((UV * 2. - 1.) + offset) * tex_rotate(-radians(start_angle));
	
	if (reflect_x) {
		uv *= mat2(vec2(-1., 0.), vec2(0., 1.));
	}
	if (reflect_y) {
		uv *= mat2(vec2(1., 0.), vec2(0., -1.));
	}
	vec4 final;
	if ((!invert_fill && atan(uv.x, uv.y) + PI < fill_angle) || (invert_fill && atan(uv.x, uv.y) + PI > fill_angle)) {
		final = texture(TEXTURE, UV) * texture(fill_texture_overlay, UV);
	} else {
		final = texture(bg_texture, UV);
	}
	COLOR.rgb = final.rgb;
	COLOR.a = min(final.a, (texture(TEXTURE, UV).a));
}