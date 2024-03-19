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

uint chunkID=0;

const uint ChunkSize=16;

layout (std430, binding=0) buffer voxelData{
	float[][ChunkSize*ChunkSize*ChunkSize] voxels;
};

struct chunk{
	uint[6] neighbors;
	uint vox;
};

layout (std430, binding=1) buffer chunkData{
	chunk[2] chunks;
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

ivec3[6] Neighbors={
	{1,0,0},{-1,0,0},
	{0,1,0},{0,-1,0},
	{0,0,1},{0,0,-1},
};

float getVoxel(ivec3 pos){
	uint c=chunkID;
	if(pos.x>=ChunkSize){
		c=chunks[c].neighbors[0];
		if(c==-1)return 0;
		pos.x-=int(ChunkSize);
	}if(pos.y>=ChunkSize){
		c=chunks[c].neighbors[2];
		if(c==-1)return 0;
		pos.y-=int(ChunkSize);
	}if(pos.z>=ChunkSize){
		c=chunks[c].neighbors[4];
		if(c==-1)return 0;
		pos.z-=int(ChunkSize);
	}
	return voxels[chunks[c].vox][pos.x+pos.y*ChunkSize+pos.z*ChunkSize*ChunkSize];
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

float interpolate(struct Voxels voxs,vec3 pos){
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
	ivec3 pos=ivec3(floor(ray));
	struct Voxels voxs=getVoxels(pos);
	float s=getSmallest(voxs);
	if(s<0.1){
		s=interpolate(voxs,ray);
	}
	return s;
}

void main(){
	vec3 up=cross(fwd,right);

	vec2 p=(-resolution.xy+2.0*gl_FragCoord.xy)/resolution.y;
	vec3 rd=normalize(p.x*right+p.y*up+fov*fwd);

	float dst=0;
	vec3 ray=pos;
	for(int i=0;i<100;i++){
		if(ray.x>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[0];
			ray.x-=ChunkSize;
			if(chunkID==-1)break;
		}else if(ray.x<0){
			chunkID=chunks[chunkID].neighbors[1];
			ray.x+=ChunkSize;
			if(chunkID==-1)break;
		}if(ray.y>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[2];
			ray.y-=ChunkSize;
			if(chunkID==-1)break;
		}else if(ray.y<0){
			chunkID=chunks[chunkID].neighbors[3];
			ray.y+=ChunkSize;
			if(chunkID==-1)break;
		}if(ray.z>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[4];
			ray.z-=ChunkSize;
			if(chunkID==-1)break;
		}else if(ray.z<0){
			chunkID=chunks[chunkID].neighbors[5];
			ray.z+=ChunkSize;
			if(chunkID==-1)break;
		}
		float geom=world(ray);
		dst+=geom;
		ray+=rd*geom;
		if(geom<0.01)
			break;
	}
	vec3 col = vec3(dst/50);
	// if(p.x<0){
	// 	col=vec3(chunks[chunkID].neighbors[0],chunks[chunkID].neighbors[1],chunks[chunkID].neighbors[2]);
	// 	if(chunkID==-1)col=vec3(1,0,0);
	// }

	finalColor = vec4(col, 1.0 );
}

