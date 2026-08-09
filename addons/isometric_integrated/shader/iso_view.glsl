#[compute]
#version 450

struct Tile{
	ivec4 position;
	ivec4 origin_pos; // 2d - ignore origin_pos.z
	ivec4 low_bound;
	ivec4 high_bound;
	vec4[1024] colors;
	vec4[1024] positions;
	vec4[1024] normals;
};

struct Light{
	ivec4 position;
	vec4 color;
	double falloff_linear;
	double falloff_quadratic;
	double strength;
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

layout(set = 2, binding = 0, std140) uniform LightCount{
	int light_count;
};

layout(set = 2, binding = 1, std430) buffer LightArray{
	Light[] light_arr;
};

layout(set = 3, binding = 0, std140) buffer DebugFloat{
	double debug_val;
};

bool ray_intersects_box(vec3 ray_start, vec3 ray_end, vec3 box_start, vec3 box_end) {
	float t_min = 0;
	float t_max = 1;
	vec3 path_vec = ray_end-ray_start;

	// pad pixels
	box_start -= vec3(0.5,0,.99);
	box_end += vec3(0.5,1.99,0);

	
	
	// calculate using the slab method, beginning with the x direction
	
	if (path_vec.x == 0) {
		if (!(box_start.x <= ray_start.x && ray_start.x <= box_end.x)) {
			return false;
		}
	} else {
	
		float t_1 = (box_start.x-ray_start.x)/path_vec.x;
		float t_2 = (box_end.x-ray_start.x)/path_vec.x;
		float t_low = min(t_1,t_2);
		float t_high = max(t_1,t_2);
		t_max = min(t_high, t_max);
		t_min = max(t_low,t_min);
		if (t_min > t_max) {
			return false;
		}
	}
	
	if (path_vec.y == 0) {
		if (!(box_start.y <= ray_start.y && ray_start.y <= box_end.y)) {
			return false;
		}
	} else {
	
		float t_1 = (box_start.y-ray_start.y)/path_vec.y;
		float t_2 = (box_end.y-ray_start.y)/path_vec.y;
		float t_low = min(t_1,t_2);
		float t_high = max(t_1,t_2);
		t_max = min(t_high, t_max);
		t_min = max(t_low,t_min);
		if (t_min > t_max) {
			return false;
		}
	}

	if (path_vec.z == 0) {
		if (!(box_start.z <= ray_start.z && ray_start.z <= box_end.z)) {
			return false;
		}
	} else {
	
		float t_1 = (box_start.z-ray_start.z)/path_vec.z;
		float t_2 = (box_end.z-ray_start.z)/path_vec.z;
		float t_low = min(t_1,t_2);
		float t_high = max(t_1,t_2);
		t_max = min(t_high, t_max);
		t_min = max(t_low,t_min);
		if (t_min > t_max) {
			return false;
		}
	}
	
	if (t_min > t_max) {
		return false;
	}
	return true;
}

float attenuation(int light_index, ivec3 target_pos) {
	ivec3 light_pos = light_arr[light_index].position.xyz;
	float x_dist = float(light_pos.x - target_pos.x);
	float y_dist = float(light_pos.y - target_pos.y);
	float z_dist = float(light_pos.z - target_pos.z);

	float dist = sqrt(x_dist*x_dist + y_dist*y_dist + z_dist*z_dist);
	return float(1.0/(1.0+light_arr[light_index].falloff_linear*dist+light_arr[light_index].falloff_quadratic*dist*dist));
}

bool casts_light(ivec3 pix_pos, Light light, int tile_index) {
	for (int i = 0; i < tile_count; i++) {
		// Don't block shadows for the same tile
		if (i == tile_index) {
			continue;
		}
		vec3 b1 = vec3(tile_arr[i].position.xyz + tile_arr[i].low_bound.xyz);
		vec3 b2 = vec3(tile_arr[i].position.xyz + tile_arr[i].high_bound.xyz);
		
		//debug_val = double(tile_arr[i].position.x);
		if (ray_intersects_box(pix_pos,light.position.xyz,b1,b2)) {
			for (int j = 0; j < 1024; j++) {
				if (tile_arr[i].colors[j].a != 0) {
					vec3 int_pos = vec3(tile_arr[i].positions[j].xyz+tile_arr[i].position.xyz);
					if (ray_intersects_box(pix_pos,light.position.xyz,int_pos,int_pos)) {
						if (pix_pos != int_pos){return false;}
					}
				}
			}
		}
	}
	return true;
}

vec4 light_color (vec4 color, ivec3 pix_pos, vec3 normal, int tile_index) {
	vec4 out_col = vec4(0,0,0,1);
	
	for (int i = 0; i < light_count; i++) {
		if(casts_light(pix_pos,light_arr[i], tile_index)){
			vec3 col = light_arr[i].color.rgb;
			vec3 light_vec = normalize(vec3(light_arr[i].position.xyz - pix_pos));
			//float dot = light_vec.x * normal.x + light_vec.y * normal.y + light_vec.z * normal.z;
			float str = float(max(dot(light_vec,normal) * light_arr[i].strength, 0.0));
			str *= attenuation(i, pix_pos);


			
			//float str = float(light_arr[i].strength);
			//out_col.rgb += vec3(light_arr[i].color.rgb*color.rgb*light_arr[i].strength);
			
			out_col.r += color.r * col.r * str;
			out_col.g += color.g * col.g * str;
			out_col.b += color.b * col.b * str;
		}
	}
	//out_col.rgb = normal.rgb;
	return out_col;	
}

void main() {
	// Set up pixel position in screen space, centered on camera
	ivec2 size = imageSize(im);
	ivec2 screenspace_pos = ivec2(gl_GlobalInvocationID.xy)-ivec2(floor(size.xy/2));
	screenspace_pos.y *= -1;
	screenspace_pos.x += pos.x;
	screenspace_pos.y += int(floor(float(pos.y)/2)) + pos.z;

	double pix_dist = cull_distance;
	vec4 col = vec4(0,0,0,0);
	ivec3 seen_pos = ivec3(0,0,0);
	vec3 seen_normal = vec3(0,0,0);
	int seen_tile = 0;
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
				seen_pos = pix_pos;
				seen_normal = tile_arr[i].normals[ind].xyz;
				seen_tile = i;
			}
		}
	}

	if (col != vec4(0,0,0,0)) {
		col = light_color(col, seen_pos, seen_normal, seen_tile);
	}


	imageStore(im,ivec2(gl_GlobalInvocationID.xy), col);
}