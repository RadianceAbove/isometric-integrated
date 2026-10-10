shader_type spatial;

uniform vec3 pixel_size = vec3(0.3125, 0.360844, 0.625);

void vertex() {
	// Code from GPT-5.6
	// The MeshInstance3D's actual world-space origin.
    vec3 world_origin = MODEL_MATRIX[3].xyz;

    // The desired, render-only origin on the world grid.
    vec3 snapped_world_origin = round(world_origin / pixel_size) * pixel_size;

    // Calculate the distance from the true position to its rendered position.
    vec3 world_offset = snapped_world_origin - world_origin;

    // MODELVIEW_MATRIX is in camera/view space, so convert the world-space
    // offset into view space before applying it.
    vec3 view_offset = (VIEW_MATRIX * vec4(world_offset, 0.0)).xyz;

    // Move the entire mesh for rendering only.
    MODELVIEW_MATRIX[3].xyz += view_offset;
}
