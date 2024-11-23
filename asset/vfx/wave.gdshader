shader_type canvas_item;

uniform sampler2D SCREEN : hint_screen_texture;

uniform float FREQUENCY = 0.5;
uniform float AMPLITUDE = 0.5;
uniform float SPEED = 2.0;


void fragment() {
	float offset = sin(VERTEX.y * FREQUENCY + TIME * SPEED) * AMPLITUDE;

	vec2 uv = SCREEN_UV;
	uv.x += offset * SCREEN_PIXEL_SIZE.x;

	COLOR = texture(SCREEN, uv);
}