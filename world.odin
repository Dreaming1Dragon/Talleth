package main

import la "core:math/linalg"

chunkType::struct{
	neighbors:[6]u32,
	vox:u32,
}
voxelType::[ChunkSize*ChunkSize*ChunkSize]f32
world:struct{
	voxelData:[dynamic]voxelType,
	chunkData:[dynamic]chunkType,
}
@(private="file")
none:=transmute(u32)i32(-1)
@(private="file")
ChunkSize::16

worldInit::proc(){
	xSize:=4
	ySize:=2
	zSize:=4
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
							// if(i==0){
							// 	dst=la.length([3]f32{xx,yy,zz}-8)
							// }
							data[x+y*ChunkSize+z*ChunkSize*ChunkSize]=dst//-(2*f32(i+1))
							// fmt.println(x,y,z,dst)
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

worldDestroy::proc(){
	delete(world.voxelData)
	delete(world.chunkData)
}

