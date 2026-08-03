#[compute]
#version 450

struct Tile{
	ivec3 position; // use top left corner
	ivec3 low_bound;
	ivec3 high_bound;
	vec4[1024] colors;
	vec3[1024] positions;
};

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) uniform CameraPos{
	ivec3 pos;
};

layout(set = 0, binding = 1, std140) uniform TileCount{
	int tile_count;
};

layout(set = 0, binding = 2, std430) buffer TileArray{
	Tile[] tile_arr;
};

layout(rgba32f, set = 1, binding = 0) uniform restrict writeonly image2D im;


void main() {
	imageStore(im,ivec2(gl_GlobalInvocationID.xy), vec4(1,0,0,1));
}