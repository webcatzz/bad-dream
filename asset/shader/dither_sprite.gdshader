shader_type canvas_item;


const mat4 BAYER = mat4(
	vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
	vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
	vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
	vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0)
);


void fragment() {
	vec2 uv = UV / TEXTURE_PIXEL_SIZE;
	COLOR.a = step(0.0, BAYER[int(uv.x) % 4][int(uv.y) % 4] + COLOR.a - 1.0);
}