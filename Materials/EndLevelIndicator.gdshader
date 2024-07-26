shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled, skip_vertex_transform;

uniform vec4 barrier_color : source_color = vec4( 0.05, 1.0, 0.5, 1.0 );
uniform float barrier_force = 1.0;
uniform float barrier_interval = 50.0;
uniform float barrier_speed = 0.1;

void vertex(){
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment( )
{	
	float yOffset = cos(UV.x * TAU * 8.0)*0.05;
	
	float t = cos((UV.y + yOffset + TIME*barrier_speed) * TAU * barrier_interval)*0.5+0.5;
	vec3 albedo = clamp(barrier_color.rgb*t*barrier_force,vec3(0,0,0),vec3(1,1,1));
	
	ALBEDO = albedo;
	ALPHA = clamp(UV.y*(1.0+t),0,1);
	if(abs(NORMAL.y)> 0.999){
		ALPHA = 0.0;
	}

}
