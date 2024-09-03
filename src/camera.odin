package main

import fl "shared:FolkLibs"

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

CameraUpdate::proc(cam:^Camera){
	// @static
	// wrapPos:[3]f32
	// cam.pos+=wrapPos
	// wrapPos={}
	fwd:=la.normalize(la.cross(cam.right,cam.up))
	speed:=deltaTime*((fl.input.keys[controls.prone].set)?2:((fl.input.keys[controls.run].set)?20:14))
	if(fl.input.keys[controls.fwd].set){
		cam.pos+=fwd*speed
	}if(fl.input.keys[controls.back].set){
		cam.pos-=fwd*speed
	}if(fl.input.keys[controls.right].set){
		cam.pos+=cam.right*speed
	}if(fl.input.keys[controls.left].set){
		cam.pos-=cam.right*speed
	}if(fl.input.keys[controls.jump].set){
		cam.pos+=cam.up*speed
	}if(fl.input.keys[controls.crouch].set){
		cam.pos-=cam.up*speed
	}
	if(cam.pos.x>ChunkSize){
		c:=world.chunkData[ChunkID].neighbors[0]
		if(c==none){
			cam.pos.x=ChunkSize
		}else{
			ChunkID=c
			cam.pos.x-=ChunkSize
			ChunkPos.x+=1
		}
	}else if(cam.pos.x<0){
		c:=world.chunkData[ChunkID].neighbors[1]
		if(c==none){
			cam.pos.x=0
		}else{
			ChunkID=c
			cam.pos.x+=ChunkSize
			ChunkPos.x-=1
		}
	}
	if(cam.pos.y>ChunkSize){
		c:=world.chunkData[ChunkID].neighbors[2]
		if(c==none){
			cam.pos.y=ChunkSize
		}else{
			ChunkID=c
			cam.pos.y-=ChunkSize
			ChunkPos.y+=1
		}
	}else if(cam.pos.y<0){
		c:=world.chunkData[ChunkID].neighbors[3]
		if(c==none){
			cam.pos.y=0
		}else{
			ChunkID=c
			cam.pos.y+=ChunkSize
			ChunkPos.y-=1
		}
	}
	if(cam.pos.z>ChunkSize){
		c:=world.chunkData[ChunkID].neighbors[4]
		if(c==none){
			cam.pos.z=ChunkSize
		}else{
			ChunkID=c
			cam.pos.z-=ChunkSize
			ChunkPos.z+=1
		}
	}else if(cam.pos.z<0){
		c:=world.chunkData[ChunkID].neighbors[5]
		if(c==none){
			cam.pos.z=0
		}else{
			ChunkID=c
			cam.pos.z+=ChunkSize
			ChunkPos.z-=1
		}
	}
	// println(fl.input.mouse)
	cam.fwd=la.matrix3_rotate(fl.input.mouse.x/500,cam.up)*cam.fwd
	cam.right=la.normalize(la.cross(cam.up,cam.fwd))
	// angle:=la.angle_between(cam.fwd,cam.up)
	cam.fwd=la.matrix3_rotate(-fl.input.mouse.y/500,cam.right)*cam.fwd
}

