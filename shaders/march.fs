#version 430

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

uniform vec3 pos;
uniform vec3 fwd;
uniform vec3 right;
// uniform vec3 up;
uniform float fov;
uniform float runTime;
uniform vec2 resolution;

layout (std430, binding=0) buffer shader_data{
	float[16*16*16] blocks;
};

float sphere(vec3 pos,float radius,vec3 ray){
	return length(pos-ray)-radius;
}

float world(vec3 ray){
	ivec3 pos=ivec3(floor(ray))+8;
	return blocks[pos.x+pos.y*16+pos.z*16*16];
	// return length(pos)/16;
	// return sphere(vec3(0),2,ray);
}

void main(){
	// vec3 tot = vec3(0.0);
	vec3 up=cross(fwd,right);

	// RAY: Camera is provided from raylib
	// vec3 ro = vec3( -0.5+3.5*cos(0.1*time + 6.0*mo.x), 1.0 + 2.0*mo.y, 0.5 + 4.0*sin(0.1*time + 6.0*mo.x) );

	vec2 p=(-resolution.xy+2.0*gl_FragCoord.xy)/resolution.y;
	// vec2 p=gl_FragCoord.xy/resolution.y-vec2(1);

	// ray direction
	vec3 rd=normalize(p.x*right+p.y*up+fov*fwd);

	// render
	float dst=0;
	for(int i=0;i<100;i++){
		vec3 ray=pos+rd*dst;
		float geom=world(ray);
		dst+=geom;
		if(geom<0.01)
			break;
	}
	vec3 col = vec3(dst/50);
	
	// vec3 vox=vec3(p*8,mod(runTime,16)-8);
	// vec3 vox=vec3(p*8,0);
	// float val=blocks[ipos.x+ipos.y*16+ipos.z*16*16];
	// vec3 col = vec3(world(vec3(p*8,mod(runTime,16.0)-8.0))+0.5,1,0);
	// vec3 col = vec3(world(vox),0,0);
	// vec3 col = vec3(floor(vox)+8)/16;

	// gamma
	// col = pow( col, vec3(0.4545) );

	// tot += col;

	finalColor = vec4(col, 1.0 );
}

