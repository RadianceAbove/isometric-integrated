#[compute]
#version 450

struct Tile{
	ivec4 position;
	ivec4 origin_pos; // 2d - ignore origin_pos.z
	ivec4 low_bound;
	ivec4 high_bound;
	vec4[1024] colors;
	vec4[1024] positions;
};

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) uniform CameraPos{
	ivec3 pos;
};

layout(set = 0, binding = 1, std140) uniform CameraCull{
	double cull_distance;
};

layout(set = 0, binding = 2, std140) uniform TileCount{
	int tile_count;
};

layout(set = 0, binding = 3, std430) buffer TileArray{
	Tile[] tile_arr;
};

layout(rgba32f, set = 1, binding = 0) uniform restrict writeonly image2D im;


void main() {
	// Set up pixel position in screen space, centered on camera
	ivec2 size = imageSize(im);
	ivec2 screenspace_pos = ivec2(gl_GlobalInvocationID.xy)-ivec2(floor(size.xy/2));
	screenspace_pos.y *= -1;
	screenspace_pos.x += pos.x;
	screenspace_pos.y += int(floor(float(pos.y)/2)) + pos.z;

	double pix_dist = cull_distance;
	vec4 col = vec4(0,0,0,1);
	ivec3 camera_pix_pos = pos;
	camera_pix_pos.x += int(gl_GlobalInvocationID.x)-int(floor(size.x/2));
	camera_pix_pos.z += int(floor(size.y/2))-int(gl_GlobalInvocationID.y);

	for (int i=0; i<tile_count; i++) {
		ivec2 tile_screenspace_pos = ivec2(tile_arr[i].position.x,0);
		tile_screenspace_pos.y += int(floor(double(tile_arr[i].position.y)/2))+tile_arr[i].position.z;
		tile_screenspace_pos.x -= tile_arr[i].origin_pos.x;
		tile_screenspace_pos.y += tile_arr[i].origin_pos.y;
		
		ivec2 screenspace_offset = ivec2(0,0);
		screenspace_offset.x += screenspace_pos.x - tile_screenspace_pos.x;
		screenspace_offset.y += tile_screenspace_pos.y - screenspace_pos.y;
		
		if (0 <= screenspace_offset.x && screenspace_offset.x < 32 && 0 <= screenspace_offset.y && screenspace_offset.y < 32) {
			int ind = screenspace_offset.x + screenspace_offset.y * 32;
			ivec3 pix_pos = ivec3(tile_arr[i].positions[ind].xyz+tile_arr[i].position.xyz);
			int x_dif = camera_pix_pos.x - pix_pos.x;
			int y_dif = camera_pix_pos.y - pix_pos.y;
			int z_dif = camera_pix_pos.z - pix_pos.z;
			double dist = sqrt(double(x_dif*x_dif+y_dif*y_dif+z_dif*z_dif));
			if (dist < pix_dist && tile_arr[i].colors[ind].a>0) {
				pix_dist = dist;
				col = tile_arr[i].colors[ind];
			}
		}
	}


	imageStore(im,ivec2(gl_GlobalInvocationID.xy), col);
}