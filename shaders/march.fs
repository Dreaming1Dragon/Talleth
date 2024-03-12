#version 430

in vec2 fragTexCoord;
in vec4 fragColor;
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

struct Voxels{
	float[8] vox;
};

ivec3[8] Corners={
	{0,0,0},{1,0,0},
	{0,1,0},{1,1,0},
	{0,0,1},{1,0,1},
	{0,1,1},{1,1,1},
};

float sphere(vec3 pos,float radius,vec3 ray){
	return length(pos-ray)-radius;
}

float getVoxel(ivec3 pos){
	return blocks[pos.x+pos.y*16+pos.z*16*16];
}

struct Voxels getVoxels(ivec3 pos){
	struct Voxels voxs;
	for(int i=0;i<8;i++){
		voxs.vox[i]=getVoxel(pos+Corners[i]);
	}
	return voxs;
}

float getSmallest(struct Voxels voxs){
	float s=1.0/0.0;
	for(int i=0;i<8;i++){
		s=min(s,voxs.vox[i]);
	}
	return s;
}

float interpoate(struct Voxels voxs,vec3 pos){
	pos-=floor(pos);
	float a1=mix(voxs.vox[0],voxs.vox[1],pos.x);
	float a2=mix(voxs.vox[2],voxs.vox[3],pos.x);
	float a3=mix(voxs.vox[4],voxs.vox[5],pos.x);
	float a4=mix(voxs.vox[6],voxs.vox[7],pos.x);
	float b1=mix(a1,a2,pos.y);
	float b2=mix(a3,a4,pos.y);
	return mix(b1,b2,pos.z);
}

float world(vec3 ray){
	ivec3 pos=ivec3(floor(ray))+8;
	struct Voxels voxs=getVoxels(pos);
	float s=getSmallest(voxs);
	if(s<2){
		s=interpoate(voxs,ray);
	}
	return s;
	// return length(pos)/16;
	// return sphere(vec3(0),2,ray);
}

void main(){
	vec3 up=cross(fwd,right);

	vec2 p=(-resolution.xy+2.0*gl_FragCoord.xy)/resolution.y;
	vec3 rd=normalize(p.x*right+p.y*up+fov*fwd);

	float dst=0;
	for(int i=0;i<100;i++){
		vec3 ray=pos+rd*dst;
		float geom=world(ray);
		dst+=geom;
		if(geom<0.01)
			break;
	}
	vec3 col = vec3(dst/50);

	// gamma
	// col = pow( col, vec3(0.4545) );

	finalColor = vec4(col, 1.0 );
}

