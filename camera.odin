package main

import rl "RenderLib"

import "core:fmt"
import la "core:math/linalg"
import "core:math"

Camera::struct{
	pos:[3]f32,
	fwd:[3]f32,
	right:[3]f32,
	up:[3]f32,
	fov:f32
}

Camera_Default::Camera{
	pos={0,0,0},
	fwd={0,0,1},
	right={1,0,0},
	up={0,1,0},
	fov=1
}

CameraUpdate::proc(Cam:^Camera){
	fwd:=la.normalize(la.cross(Cam.right,Cam.up))
	speed:=deltaTime*((rl.input.keys[controls.prone].set)?2:((rl.input.keys[controls.run].set)?20:14))
	if(rl.input.keys[controls.fwd].set){
		Cam.pos+=fwd*speed
	}if(rl.input.keys[controls.back].set){
		Cam.pos-=fwd*speed
	}if(rl.input.keys[controls.right].set){
		Cam.pos+=Cam.right*speed
	}if(rl.input.keys[controls.left].set){
		Cam.pos-=Cam.right*speed
	}if(rl.input.keys[controls.jump].set){
		Cam.pos+=Cam.up*speed
	}if(rl.input.keys[controls.crouch].set){
		Cam.pos-=Cam.up*speed
	}
	if(Cam.pos.x>ChunkSize-0.01){
		c:=world.chunkData[ChunkID].neighbors[0]
		if(c==none){
			Cam.pos.x=ChunkSize-0.01
		}else{
			ChunkID=c
			Cam.pos.x-=ChunkSize
		}
	}else if(Cam.pos.x<0){
		c:=world.chunkData[ChunkID].neighbors[1]
		if(c==none){
			Cam.pos.x=0
		}else{
			ChunkID=c
			Cam.pos.x+=ChunkSize
		}
	}
	if(Cam.pos.y>ChunkSize-0.01){
		c:=world.chunkData[ChunkID].neighbors[2]
		if(c==none){
			Cam.pos.y=ChunkSize-0.01
		}else{
			ChunkID=c
			Cam.pos.y-=ChunkSize
		}
	}else if(Cam.pos.y<0){
		c:=world.chunkData[ChunkID].neighbors[3]
		if(c==none){
			Cam.pos.y=0
		}else{
			ChunkID=c
			Cam.pos.y+=ChunkSize
		}
	}
	if(Cam.pos.z>ChunkSize-0.01){
		c:=world.chunkData[ChunkID].neighbors[4]
		if(c==none){
			Cam.pos.z=ChunkSize-0.01
		}else{
			ChunkID=c
			Cam.pos.z-=ChunkSize
		}
	}else if(Cam.pos.z<0){
		c:=world.chunkData[ChunkID].neighbors[5]
		if(c==none){
			Cam.pos.z=0
		}else{
			ChunkID=c
			Cam.pos.z+=ChunkSize
		}
	}
	// fmt.println(rl.input.mouse)
	Cam.fwd=la.matrix3_rotate(rl.input.mouse.x/500,Cam.up)*Cam.fwd
	Cam.right=la.normalize(la.cross(Cam.up,Cam.fwd))
	// angle:=la.angle_between(Cam.fwd,Cam.up)
	Cam.fwd=la.matrix3_rotate(-rl.input.mouse.y/500,Cam.right)*Cam.fwd
}

