package main

import rl "RenderLib"
import "vendor:glfw"

import "core:fmt"

controls::enum{
	fwd,back,
	right,left,
	jump,crouch,
	pause,
}

Cam:Camera=Camera_Default
Keys:[]rl.KeyBind={
	{hold=true,code=glfw.KEY_W},	         // .fwd
	{hold=true,code=glfw.KEY_S},	         // .back
	{hold=true,code=glfw.KEY_D},	         // .right
	{hold=true,code=glfw.KEY_A},	         // .left
	{hold=true,code=glfw.KEY_SPACE},	     // .jump
	{hold=true,code=glfw.KEY_LEFT_SHIFT},	// .crouch
	{hold=false,code=glfw.KEY_ESCAPE},	   // .pause
}

gameInit::proc(){
	Cam.pos={8,8,8-5}
	rl.CaptureCursor()
	rl.inputInit(Keys)
}

menuUpdate::proc(){
	if(rl.input.keys[controls.pause].set){
		rl.CaptureCursor()
		runningScreen=gameUpdate
	}
}

gameUpdate::proc(){
	if(rl.input.keys[controls.pause].set){
		rl.ReleaseCursor()
		runningScreen=menuUpdate
	}
	CameraUpdate(&Cam)
	// fmt.println("pos: ",Cam.pos)
}

