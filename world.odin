package main

import "core:fmt"
import la "core:math/linalg"

chunkType::struct{
	neighbors:[6]u32,
	vox:u32,
}
voxelType::[ChunkSize*ChunkSize*ChunkSize]f32
world:struct{
	voxelData:[dynamic]voxelType,
	chunkData:[dynamic]chunkType,
	// chunks:[dynamic]struct{
	// 	parent:u32,
	// 	children:[8]u32,
	// },
}
ChunkSize::16
ChunkID:u32=0
none:=transmute(u32)i32(-1)
@(private="file")
xSize:=8
@(private="file")
ySize:=2
@(private="file")
zSize:=8

worldInit::proc(){
	for cx in 0..<xSize{
		for cy in 0..<ySize{
			for cz in 0..<zSize{
				data:voxelType
				for x in 0..<ChunkSize{
					for y in 0..<ChunkSize{
						for z in 0..<ChunkSize{
							xx:=f32(cx*ChunkSize+x)
							yy:=f32(cy*ChunkSize+y)
							zz:=f32(cz*ChunkSize+z)
							dst:=yy-(la.sin(xx/20)+la.sin(zz/10)+5)
							data[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst
						}
					}
				}
				append(&world.voxelData,data)
				append(&world.chunkData,chunkType{
					neighbors={
						none,none,
						none,none,
						none,none,
					},
					vox=u32(len(world.voxelData)-1),
				})
				if cx>0{
					ind:=u32(cz+cy*xSize+(cx-1)*xSize*ySize)
					last(world.chunkData).neighbors[1]=ind
					world.chunkData[ind].neighbors[0]=u32(len(world.chunkData)-1)
				}
				if cy>0{
					ind:=u32(cz+(cy-1)*xSize+cx*xSize*ySize)
					last(world.chunkData).neighbors[3]=ind
					world.chunkData[ind].neighbors[2]=u32(len(world.chunkData)-1)
				}
				if cz>0{
					ind:=u32((cz-1)+cy*xSize+cx*xSize*ySize)
					last(world.chunkData).neighbors[5]=ind
					world.chunkData[ind].neighbors[4]=u32(len(world.chunkData)-1)
				}
			}
		}
	}
}

worldUpdate::proc(){
	for v,i in &world.voxelData{
		cz:=i%zSize
		cy:=(i/zSize)%ySize
		cx:=(i/(zSize*ySize))%xSize
		for x in 0..<ChunkSize{
			for y in 0..<ChunkSize{
				for z in 0..<ChunkSize{
					xx:=f32(cx*ChunkSize+x)
					yy:=f32(cy*ChunkSize+y)
					zz:=f32(cz*ChunkSize+z)
					dst:=yy-(la.sin(xx/20+runTime)+la.sin(zz/10)+5)
					v[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst
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
	ChunkID=0
}

worldDestroy::proc(){
	delete(world.voxelData)
	delete(world.chunkData)
}

