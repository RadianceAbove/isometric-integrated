#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer ImageSize {
	int height;
	int width;
} image_size;
layout(set = 1, binding = 0, std430) restrict buffer VisiblePointPositions {
	vec4 data[];
} visible_point_positions;
layout(set = 2, binding = 0, std430) restrict buffer VisiblePointColors {
	vec4 data[];
} visible_point_color;

void main () {
	int index = int(gl_GlobalInvocationID.x) + image_size.height * int(gl_GlobalInvocationID.y);
	vec4 color = vec4(1,0,0,1);//visible_point_color[index]
	float val = float(index)/(image_size.height*image_size.width);
	color = vec4(val, val, val, 1);
	color = vec4(visible_point_positions.data[index].xyz/64,1);
	color = color + vec4(.5,.5,.5,0);
	visible_point_color.data[index] = color;
}
