package main

import "core:fmt"
import la "core:math/linalg"
import math "core:math"

chunkType::struct{
	neighbors:[6]u32,
	vox:u32,
	id:u32
}
voxelType::[ChunkSize*ChunkSize*ChunkSize]f32
chunksType::struct{
	pos:[3]i32,
	parent:Maybe([2]u32),
	children:[8]Maybe(u32),
	neighbors:[6]Maybe(u32),
	// vox:voxelType,
	chunk:Maybe(u32)
}
world:struct{
	voxelData:[dynamic]voxelType,
	chunkData:[dynamic]chunkType,
	chunks:[dynamic]chunksType,
}
ChunkSize::16
ChunkID:u32
ChunkPos:[3]i32
ChunksPos:[3]i32
none:=transmute(u32)i32(-1)
@(private="file")
xSize:=8
@(private="file")
ySize:=2
@(private="file")
zSize:=8

@(private="file")
Corners:[8][3]i32={
	{0,0,0},{1,0,0},
	{0,1,0},{1,1,0},
	{0,0,1},{1,0,1},
	{0,1,1},{1,1,1},
}
@(private="file")
Neighbors:[6][3]i32={
	{1,0,0},{-1,0,0},
	{0,1,0},{0,-1,0},
	{0,0,1},{0,0,-1},
}

worldInit::proc(){
	{
		append(&world.chunks,chunksType{pos={0,0,0}})
		next::proc(dir:u32)->u32{
			switch dir{
				case 4:return 0
				case 0:return 5
				case 5:return 1
				case 1:return 4
			}
			return 6
		}
		dir:u32=4
		chunk:u32
		pos:[3]i32
		for _ in 0..<50{
			// fmt.println("GenChunk",Neighbors[dir],"from",chunk,pos)
			chunk=genNeighbor(chunk,dir)
			// fmt.println(pos,dir)
			pos+=Neighbors[dir]
			world.chunks[chunk].pos=pos
			neighbor:bool
			for j in 0..<6{
				j:=u32(j)
				n,ok:=world.chunks[chunk].neighbors[j].?
				if !ok{
					// fmt.println("----------------")
					// fmt.println("Find ",Neighbors[j]," from ",chunk)
					n,ok=findNeighbor(chunk,j).?
					if ok{
						world.chunks[chunk].neighbors[j]=n
						world.chunks[n].neighbors[i32(j)-((i32(j)%2)*2-1)]=chunk
					}
					// fmt.println("----------------")
					// fmt.println(j,ok,next(dir),n)
				}
				if(ok && j==next(dir))do neighbor=true
			}
			// fmt.println(neighbor,dir)
			if !neighbor{
				dir=next(dir)
			}
		}
		// fmt.println("pos:",pos)
	}
	ind:u32
	for &c in world.chunks{
		ground:=true
		for child in c.children{
			if child!=nil do ground=false
		}
		if !ground do continue
		c.chunk=ind
		ind+=1
	}
	// fmt.println(ind)
	for c,ind in &world.chunks{
		ground:=true
		for child in c.children{
			if child!=nil do ground=false
		}
		if !ground do continue
		// fmt.println(c)
		data:voxelType
		for x in 0..<ChunkSize{
			for y in 0..<ChunkSize{
				for z in 0..<ChunkSize{
					xx:=f32(c.pos.x*ChunkSize+i32(x))
					yy:=f32(c.pos.y*ChunkSize+i32(y))
					zz:=f32(c.pos.z*ChunkSize+i32(z))
					dst:=yy-(la.sin(xx/20)+la.sin(zz/10)+5)
					dst=la.min(dst,la.length([3]f32{xx,yy,zz}-8)-2)
					// dst=la.length([3]f32{xx,yy,zz}-8)-2
					data[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst
				}
			}
		}
		append(&world.voxelData,data)
		chunk:=chunkType{
			vox=u32(len(world.voxelData)-1),
		}
		for &n,i in chunk.neighbors{
			n=none
			other,ok:=c.neighbors[i].?
			if !ok do continue
			n=world.chunks[other].chunk.?
			// assert(ok)
			// if !ok do n=none
		}
		append(&world.chunkData,chunk)
		last(world.chunkData).id=u32(ind)
	}
}

Voxels::struct{
	neighbors:[8]f32,
	corners:[8]f32,
}

getVoxel::proc(pos:[3]i32,c:u32)->f32{
	pos:=pos
	c:=c
	if(pos.x>=ChunkSize){
		c=world.chunkData[c].neighbors[0];
		if(c==none)do return 0;
		pos.x-=ChunkSize;
	}else if(pos.x<0){
		c=world.chunkData[c].neighbors[1];
		if(c==none)do return 0;
		pos.x+=ChunkSize;
	}if(pos.y>=ChunkSize){
		c=world.chunkData[c].neighbors[2];
		if(c==none)do return 0;
		pos.y-=ChunkSize;
	}else if(pos.y<0){
		c=world.chunkData[c].neighbors[3];
		if(c==none)do return 0;
		pos.y+=ChunkSize;
	}if(pos.z>=ChunkSize){
		c=world.chunkData[c].neighbors[4];
		if(c==none)do return 0;
		pos.z-=ChunkSize;
	}else if(pos.z<0){
		c=world.chunkData[c].neighbors[5];
		if(c==none)do return 0;
		pos.z+=ChunkSize;
	}
	a:=world.chunkData[c].vox
	b:=&world.voxelData[a]
	d:=pos.x+pos.y*ChunkSize+pos.z*ChunkSize*ChunkSize
	return b[pos.x+pos.y*ChunkSize+pos.z*ChunkSize*ChunkSize]
	// if d>=0 && d<ChunkSize*ChunkSize*ChunkSize{
	// }
	// return 0
}

// getVoxels::proc(pos:[3]i32,dir:[3]i32,c:u32)->(voxs:Voxels){
// 	for i in 0..<8{
// 		voxs.corners[i]=getVoxel(pos+Corners[i]*dir,c);
// 	}
// 	for i in 0..<6{
// 		voxs.neighbors[i]=getVoxel(pos+(Neighbors[i]*2-1),c);
// 	}
// 	return;
// }

getVoxels::proc(pos:[3]i32,c:u32)->(voxs:Voxels){
	for i in 0..<8{
		voxs.corners[i]=getVoxel(pos+(Corners[i]*2-1),c);
	}
	for i in 0..<6{
		voxs.neighbors[i]=getVoxel(pos+Neighbors[i],c);
	}
	return;
}

worldUpdate::proc(){
	when true{
		for c in &world.chunks{
			ground:=true
			for child in c.children{
				if child!=nil do ground=false
			}
			if !ground do continue
			v:=&world.voxelData[world.chunkData[c.chunk.?].vox]
		// for v,i in &world.voxelData{
		// 	cz:=i%zSize
		// 	cy:=(i/zSize)%ySize
		// 	cx:=(i/(zSize*ySize))%xSize
			for x in 0..<ChunkSize{
				for y in 0..<ChunkSize{
					for z in 0..<ChunkSize{
						xx:=f32(c.pos.x*ChunkSize+i32(x))
						yy:=f32(c.pos.y*ChunkSize+i32(y))
						zz:=f32(c.pos.z*ChunkSize+i32(z))
						dst:=yy-(la.sin(xx/20+runTime)+la.sin(zz/10)+5)
						dst=la.min(dst,la.length([3]f32{xx,yy,zz}-8)-2)
						v[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst
					}
				}
			}
		}
	}else{
		if la.mod(runTime,5)<0.1{
			for c in &world.chunks{
				ground:=true
				for child in c.children{
					if child!=nil do ground=false
				}
				if !ground do continue
				v:=&world.voxelData[world.chunkData[c.chunk.?].vox]
				for x in 0..<ChunkSize{
					for y in 0..<ChunkSize{
						for z in 0..<ChunkSize{
							// dir:=([3]i32)({0,0,0})
							// smallest:f32=100
							// for vec in Corners{
							// 	vec:=vec*2-1
							// 	vox:=la.abs(getVoxel(([3]i32)({i32(x),i32(y),i32(z)})+vec,c.chunk.?))
							// 	if vox<smallest{
							// 		dir=vec
							// 		smallest=vox
							// 	}
							// }
							dst:f32=v[x+y*ChunkSize+z*ChunkSize*ChunkSize]
							if dst>0.1 do dst=100
							voxs:=getVoxels(([3]i32)({i32(x),i32(y),i32(z)}),c.chunk.?)
							// dst:f32=100
							for val in voxs.neighbors{
								dst=la.min(dst,val+1)
							}
							// for val in voxs.corners{
							// 	dst=la.min(dst,val+1.732050808)
							// }
							v[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst
						}
					}
				}
			}
		}
	}
	
	c:=world.chunkData[ChunkID]
	world.chunkData[ChunkID]=world.chunkData[0]
	for i in 0..<6{
		n:=world.chunkData[ChunkID].neighbors[i]
		if(n!=none && n!=ChunkID){
			world.chunkData[n].neighbors[i+((i%2==0)?1:-1)]=ChunkID
		}else if(n==ChunkID){
			c.neighbors[i+((i%2==0)?1:-1)]=ChunkID
		}
	}
	world.chunkData[0]=c
	for i in 0..<6{
		n:=world.chunkData[0].neighbors[i]
		if(n!=none){
			world.chunkData[n].neighbors[i+((i%2==0)?1:-1)]=0
		}
	}
	world.chunks[world.chunkData[0].id].chunk=0
	world.chunks[world.chunkData[ChunkID].id].chunk=ChunkID
	ChunkID=0
	
	// ChunksPos=world.chunks[world.chunkData[0].id].pos
	// fmt.println("ChunksPos:",ChunksPos)
	// fmt.println("ChunkPos:",ChunkPos)
}

worldDestroy::proc(){
	delete(world.chunks)
	delete(world.voxelData)
	delete(world.chunkData)
}

findNeighbor::proc(chunk:u32,dir:u32)->Maybe(u32){
	c:[2]u32={chunk,0}
	ok:bool
	pos:[3]f32
	pvec:[3]i32
	height:i32
	for{
		c,ok=world.chunks[c[0]].parent.?
		if !ok do return nil
		pvec=Corners[c[1]]
		pos=(pos+{f32(pvec[0]),f32(pvec[1]),f32(pvec[2])})/2
		height+=1
		// fmt.println("pvec:",pvec,c[0])
		if pvec[dir/2]==i32(dir%2) do break
	}
	// fmt.println("pos:",pos)
	pos[dir/2]+=(1/math.pow(2,f32(height)))*-(f32(dir%2)*2-1)
	// step:=(1/math.pow(2,f32(height)))
	// sign:=-(f32(dir%2)*2-1)
	// pos[dir/2]+=step*sign
	// fmt.println("pos:",pos,step,sign)
	for height>0{
		pos*=2
		pvec={i32(pos[0]),i32(pos[1]),i32(pos[2])}
		pos-={f32(pvec[0]),f32(pvec[1]),f32(pvec[2])}
		c[1]=u32(pvec[0]+pvec[1]*2+pvec[2]*4)
		c[0],ok=world.chunks[c[0]].children[c[1]].?
		if(!ok){return nil}
		height-=1
		// fmt.println("pos:",pos)
		// fmt.println("pvec:",pvec,c[0])
	}
	return c[0]
}

genNeighbor::proc(chunk:u32,dir:u32)->u32{
	fun:[3]u32={1,2,4}
	c:[2]u32={chunk,0}
	ok:bool
	pos:[3]f32
	pvec:[3]i32
	height:i32
	for{
		temp:=c[0]
		c,ok=world.chunks[c[0]].parent.?
		if !ok{
			chunk:chunksType
			c[1]=(dir%2)*7
			chunk.children[c[1]]=temp
			append(&world.chunks,chunk)
			c[0]=u32(len(world.chunks)-1)
			world.chunks[temp].parent=c
		}
		pvec=Corners[c[1]]
		pos=(pos+{f32(pvec[0]),f32(pvec[1]),f32(pvec[2])})/2
		height+=1
		// fmt.println("pos:",pos)
		// fmt.println("pvec:",pvec,c[0])
		if pvec[dir/2]==i32(dir%2) do break
	}
	// fmt.println("pos:",pos)
	pos[dir/2]+=(1/math.pow(2,f32(height)))*-(f32(dir%2)*2-1)
	// fmt.println("pos:",pos)
	// step:=(1/math.pow(2,f32(height)))
	// sign:=-(f32(dir%2)*2-1)
	// pos[dir/2]+=step*sign
	// fmt.println("pos:",pos,step,sign)
	for height>0{
		pos*=2
		pvec={i32(pos[0]),i32(pos[1]),i32(pos[2])}
		pos-={f32(pvec[0]),f32(pvec[1]),f32(pvec[2])}
		c[1]=u32(pvec[0]+pvec[1]*2+pvec[2]*4)
		temp:=c[0]
		c[0],ok=world.chunks[c[0]].children[c[1]].?
		if !ok{
			append(&world.chunks,chunksType{parent=[2]u32{temp,c[1]}})
			c[0]=u32(len(world.chunks)-1)
			world.chunks[temp].children[c[1]]=c[0]
			// fmt.println("GenDown:",temp)
		}
		height-=1
		// fmt.println("pos:",pos)
		// fmt.println("pvec:",pvec,c[0])
	}
	return c[0]
}

