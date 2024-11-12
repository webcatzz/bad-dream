shader_type canvas_item;


uniform vec4 color : source_color = vec4(1.0);


void fragment() {
	vec2 pixel = UV / TEXTURE_PIXEL_SIZE;
	if (texture(TEXTURE, TEXTURE_PIXEL_SIZE * pixel).a < 0.5 && (
		texture(TEXTURE, TEXTURE_PIXEL_SIZE * (pixel - vec2(1.0, 0.0))).a > 0.5 ||
		texture(TEXTURE, TEXTURE_PIXEL_SIZE * (pixel - vec2(0.0, 1.0))).a > 0.5 ||
		texture(TEXTURE, TEXTURE_PIXEL_SIZE * (pixel + vec2(1.0, 0.0))).a > 0.5 ||
		texture(TEXTURE, TEXTURE_PIXEL_SIZE * (pixel + vec2(0.0, 1.0))).a > 0.5
	)) COLOR = vec4(0.0, 0.0, 1.0, 1.0 - UV.y);
}