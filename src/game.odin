package main

import fl "shared:FolkLibs"
import "vendor:glfw"

import "core:fmt"

controls::enum{
	fwd,back,
	right,left,
	jump,crouch,prone,run,
	pause,
}

Cam:Camera=Camera_Default
Keys:[]fl.KeyBind={
	{hold=true,code=glfw.KEY_W},	         // .fwd
	{hold=true,code=glfw.KEY_S},	         // .back
	{hold=true,code=glfw.KEY_D},	         // .right
	{hold=true,code=glfw.KEY_A},	         // .left
	{hold=true,code=glfw.KEY_SPACE},	     // .jump
	{hold=true,code=glfw.KEY_LEFT_SHIFT},	// .crouch
	{hold=true,code=glfw.KEY_LEFT_CONTROL},	// .prone
	{hold=true,code=glfw.KEY_R},	// .run
	{hold=false,code=glfw.KEY_ESCAPE},	   // .pause
}

gameInit::proc(){
	Cam.pos={8,8,8-5}
	fl.CaptureCursor()
	fl.inputInit(Keys)
}

menuUpdate::proc(){
	if(fl.input.keys[controls.pause].set){
		fl.CaptureCursor()
		runningScreen=gameUpdate
	}
}

gameUpdate::proc(){
	if(fl.input.keys[controls.pause].set){
		fl.ReleaseCursor()
		runningScreen=menuUpdate
	}
	worldUpdate()
	CameraUpdate(&Cam)
	// println("pos: ",Cam.pos)
}

