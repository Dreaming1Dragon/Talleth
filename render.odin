package main

import rl "RenderLib"

import "core:fmt"
import la "core:math/linalg"

quit:bool
runTime:f32

@(private="file")
shader:u32
@(private="file")
buffer:u32
@(private="file")
LocNames::enum{
	pos,
	fwd,
	right,
	fov,
	runTime,
	resolution,
}
@(private="file")
Loc:[LocNames]i32
@(private="file")
shader_data:struct{
	blocks:[16*16*16]f32
}

renderInit::proc(width,height:i32,name:cstring)->(ok:bool=true){
	rl.InitWindow(width,height,name) or_return
	defer if !ok{rl.DestroyWindow()}

	shader=rl.LoadShader("../shaders/simple.vs","../shaders/march.fs") or_return
	for x in 0..<16{
		for y in 0..<16{
			for z in 0..<16{
				dst:=la.length([3]f32{f32(x),f32(y),f32(z)}-8)
				shader_data.blocks[x+y*16+z*16*16]=dst-2
				// fmt.println(x,y,z,dst)
			}
		}
	}
	buffer=rl.LoadShaderBuffer(size_of(shader_data),&shader_data)//rl.RL_DYNAMIC_COPY)
	rl.BindShaderBuffer(buffer,0)

	Loc=rl.GetUniforms(shader,([LocNames]cstring)({
		.pos="pos",
		.fwd="fwd",
		.right="right",
		.fov="fov",
		.runTime="runTime",
		.resolution="resolution",
	}))
	rl.SetUniform(Loc[.resolution],rl.resolution)
	return
}

renderUpdate::proc(){
	rl.BeginDrawing()
		runTime=rl.runTime

		rl.SetUniform(Loc[.pos],Cam.pos)
		rl.SetUniform(Loc[.fwd],Cam.fwd)
		rl.SetUniform(Loc[.right],Cam.right)
		// rl.SetShaderValue(Loc.up,&Cam.up,.VEC3)
		rl.SetUniform(Loc[.fov],Cam.fov)
		rl.SetUniform(Loc[.runTime],runTime)
		rl.SetUniform(Loc[.resolution],rl.resolution)
		
		runningScreen()
		
		rl.ScreenShader(shader)
	rl.EndDrawing()
	free_all(context.temp_allocator)
	quit|=rl.quit
}

renderDestroy::proc(){
	// rl.rlUnloadShaderBuffer(buffer)
	// rl.UnloadShader(shader)
	rl.DestroyWindow()	
}

