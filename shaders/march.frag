#version 450

layout(location = 0) in vec2 fragCoord;
layout(location = 0) out vec4 finalColor;

layout(binding = 0) uniform UniformBufferObject {
	vec3 pos;
	vec3 fwd;
	vec3 right;
	// vec3 up;
	float fov;
	float runTime;
	vec2 resolution;
} ubo;

uint chunkID=0;

const uint ChunkSize=16;

layout (std430, binding=1) readonly buffer voxelData{
	float[][ChunkSize*ChunkSize*ChunkSize] voxels;
};

struct chunk{
	uint[6] neighbors;
	uint vox;
	uint id;
	uint set;
	uint index;
};

layout (std430, binding=2) buffer chunkData{
	int lock;
	int indices;
	chunk[] chunks;
};

// layout(std430,binding=3) buffer nextData{
// 	uint[] index;
// }

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

Voxels getVoxels(ivec3 pos){
	Voxels voxs;
	for(int i=0;i<8;i++){
		voxs.vox[i]=getVoxel(pos+Corners[i]);
	}
	return voxs;
}

float getSmallest(Voxels voxs){
	float s=1.0/0.0;
	for(int i=0;i<8;i++){
		s=min(s,voxs.vox[i]);
	}
	return s;
}

float interpolate(Voxels voxs,vec3 pos){
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
	if(pos==ivec3(8,8,16)){
		return -2;
	}
	Voxels voxs=getVoxels(pos);
	float s=getSmallest(voxs);
	if(s<0.1){
		s=interpolate(voxs,ray);
	}
	return s;
}

// 0 0 0 0
// 1 2 3 4
// ^
// oldID=1
// 1 0 0 0
// 1 2 3 4
//   ^
// oldID=4
// 1 4 0 0
// 1 4 3 2
//     ^
// oldID=2
// 1 4 4 0
// 1 4 2 3
//       ^
// oldID=3
// 1 4 4 4
// 1 4 2 3

void updateChunks(uint oldID){
	// uint set=atomicCompSwap(chunks[oldID].set,0,indices);
	// if(set==0){
	// 	uint val=chunks[indices].set;
	// 	// if val!=0{}
	// 	atomicExchange(chunks[indices].index,oldID);
	// 	// atomicExchange(chunks[oldID].index,oldInd);
	// 	atomicAdd(indices,1);
	// }
	uint set=atomicExchange(chunks[oldID].set,1);
	// uint set=atomicCompSwap(chunks[oldID].set,0,indices+1);
	if(set==0){
		uint other=oldID+1;
		uint prev;
		do{
			prev=other;
			other=chunks[other-1].index;
			// other=atomicCompSwap(chunks[other-1].index,0,oldID+1);
		}while(other!=0);
		atomicExchange(chunks[indices].index,prev);
		// uint val=oldID;
		// uint ind=indices;
		// do{
		// 	uint tmp=chunks[ind].set;
		// 	if(tmp!=0){
		// 		val=tmp-1;
		// 	}else val=tmp;
		// }while(tmp!=0);
		// atomicExchange(chunks[indices].index,val);
		// atomicExchange(chunks[oldID].index,oldInd);
		atomicAdd(indices,1);
	}
}

void main(){
	vec3 up=cross(ubo.fwd,ubo.right);
	// float t=(sin(ubo.runTime)+1)/2;

	// vec2 p=(-ubo.resolution.xy+2.0*gl_FragCoord.xy)/ubo.resolution.y;
	vec2 p=fragCoord;
	if(ubo.resolution.x>ubo.resolution.y)
		p.x*=ubo.resolution.x/ubo.resolution.y;
	else
		p.y*=ubo.resolution.y/ubo.resolution.x;
	vec3 rd=normalize(p.x*ubo.right+p.y*up+ubo.fov*ubo.fwd);

	float dst=1;
	vec3 ray=ubo.pos+rd;
	// ray.y+=t;
	uint oldID=chunkID;
	for(int i=0;i<500;i++){
		oldID=chunkID;
		if(ray.x>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[0];
			ray.x-=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}else if(ray.x<0){
			chunkID=chunks[chunkID].neighbors[1];
			ray.x+=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}if(ray.y>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[2];
			ray.y-=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}else if(ray.y<0){
			chunkID=chunks[chunkID].neighbors[3];
			ray.y+=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}if(ray.z>=ChunkSize){
			chunkID=chunks[chunkID].neighbors[4];
			ray.z-=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}else if(ray.z<0){
			chunkID=chunks[chunkID].neighbors[5];
			ray.z+=ChunkSize;
			if(chunkID==-1)break;
			// break;
		}
		if(oldID!=chunkID){
			updateChunks(oldID);
		}
		float geom=world(ray);
		// float geom=.1;
		dst+=geom;
		ray+=rd*geom;
		if(geom<0.01 || dst>100)
			break;
	}
	updateChunks(oldID);
	// {
	// 	int set=atomicExchange(chunks[oldID].set,1);
	// 	if(set==0){
	// 		atomicExchange(chunks[indices].index,chunks[oldID].id);
	// 		// atomicExchange(chunks[oldID].index,oldInd);
	// 		atomicAdd(indices,1);
	// 	}
	// }
	vec3 col = vec3(0.5-(dst/200));
	// if(dst<2){
	// 	col-=vec3(1,0,1);
	// 	col+=dst*vec3(0.5,0,0.5);
	// }
	// if(chunkID!=-1)
		col+=vec3(float(chunks[oldID].id)/1000)/(1-vec3(0.8,0.3,0.7));
		// col+=vec3(float(oldID)/1000)/(1-vec3(0.8,0.3,0.7));
	// if(p.x<0){
	// 	col=vec3(chunks[chunkID].neighbors[0],chunks[chunkID].neighbors[1],chunks[chunkID].neighbors[2]);
	// 	if(chunkID==-1)col=vec3(1,0,0);
	// }

	// finalColor = vec4(p,(sin(ubo.runTime)+1)/2, 1.0 );
	finalColor = vec4(world(ray)+.1,dst/200,0,1);
	// if(p.x>1 || p.x<-1 || p.y>1 || p.y<-1){
	// 	finalColor=vec4(0,0,0,0);
	// }
	finalColor=vec4(col,0);
}

