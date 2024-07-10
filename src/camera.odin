package main

// import fl "shared:FolkLibs"

// import "core:fmt"
// import la "core:math/linalg"
// import "core:math"

// Camera::struct{
// 	pos:[3]f32,
// 	fwd:[3]f32,
// 	right:[3]f32,
// 	up:[3]f32,
// 	fov:f32
// }

// Camera_Default::Camera{
// 	pos={0,0,0},
// 	fwd={0,0,1},
// 	right={1,0,0},
// 	up={0,1,0},
// 	fov=1
// }

// CameraUpdate::proc(Cam:^Camera){
// 	fwd:=la.normalize(la.cross(Cam.right,Cam.up))
// 	speed:=deltaTime*((fl.input.keys[controls.prone].set)?2:((fl.input.keys[controls.run].set)?20:14))
// 	if(fl.input.keys[controls.fwd].set){
// 		Cam.pos+=fwd*speed
// 	}if(fl.input.keys[controls.back].set){
// 		Cam.pos-=fwd*speed
// 	}if(fl.input.keys[controls.right].set){
// 		Cam.pos+=Cam.right*speed
// 	}if(fl.input.keys[controls.left].set){
// 		Cam.pos-=Cam.right*speed
// 	}if(fl.input.keys[controls.jump].set){
// 		Cam.pos+=Cam.up*speed
// 	}if(fl.input.keys[controls.crouch].set){
// 		Cam.pos-=Cam.up*speed
// 	}
// 	if(Cam.pos.x>ChunkSize){
// 		c:=world.chunkData[ChunkID].neighbors[0]
// 		if(c==none){
// 			Cam.pos.x=ChunkSize
// 		}else{
// 			ChunkID=c
// 			Cam.pos.x-=ChunkSize
// 			ChunkPos.x+=1
// 		}
// 	}else if(Cam.pos.x<0){
// 		c:=world.chunkData[ChunkID].neighbors[1]
// 		if(c==none){
// 			Cam.pos.x=0
// 		}else{
// 			ChunkID=c
// 			Cam.pos.x+=ChunkSize
// 			ChunkPos.x-=1
// 		}
// 	}
// 	if(Cam.pos.y>ChunkSize){
// 		c:=world.chunkData[ChunkID].neighbors[2]
// 		if(c==none){
// 			Cam.pos.y=ChunkSize
// 		}else{
// 			ChunkID=c
// 			Cam.pos.y-=ChunkSize
// 			ChunkPos.y+=1
// 		}
// 	}else if(Cam.pos.y<0){
// 		c:=world.chunkData[ChunkID].neighbors[3]
// 		if(c==none){
// 			Cam.pos.y=0
// 		}else{
// 			ChunkID=c
// 			Cam.pos.y+=ChunkSize
// 			ChunkPos.y-=1
// 		}
// 	}
// 	if(Cam.pos.z>ChunkSize){
// 		c:=world.chunkData[ChunkID].neighbors[4]
// 		if(c==none){
// 			Cam.pos.z=ChunkSize
// 		}else{
// 			ChunkID=c
// 			Cam.pos.z-=ChunkSize
// 			ChunkPos.z+=1
// 		}
// 	}else if(Cam.pos.z<0){
// 		c:=world.chunkData[ChunkID].neighbors[5]
// 		if(c==none){
// 			Cam.pos.z=0
// 		}else{
// 			ChunkID=c
// 			Cam.pos.z+=ChunkSize
// 			ChunkPos.z-=1
// 		}
// 	}
// 	// fmt.println(fl.input.mouse)
// 	Cam.fwd=la.matrix3_rotate(fl.input.mouse.x/500,Cam.up)*Cam.fwd
// 	Cam.right=la.normalize(la.cross(Cam.up,Cam.fwd))
// 	// angle:=la.angle_between(Cam.fwd,Cam.up)
// 	Cam.fwd=la.matrix3_rotate(-fl.input.mouse.y/500,Cam.right)*Cam.fwd
// }

