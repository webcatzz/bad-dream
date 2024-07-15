shader_type canvas_item;


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
	float time = TIME * 2.0;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(sin(time), cos(time)) * 0.003);
	COLOR += (cos(TIME) + 1.0) * 0.005;
}