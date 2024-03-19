package main

import rl "RenderLib"

import "core:fmt"
import la "core:math/linalg"

quit:bool
deltaTime:f32
runTime:f32

@(private="file")
shader:u32
@(private="file")
voxels:u32
@(private="file")
chunks:u32
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

last::proc(arr:[dynamic]$T)->^T{
	return &arr[len(arr)-1]
}

renderInit::proc(width,height:i32,name:cstring)->(ok:bool=true){
	rl.InitWindow(width,height,name) or_return
	defer if !ok{rl.DestroyWindow()}

	shader=rl.LoadShader("../shaders/simple.vs","../shaders/march.fs") or_return
	voxels=rl.LoadShaderBuffer(size_of(voxelType)*len(world.voxelData),raw_data(world.voxelData[:]))
	rl.BindShaderBuffer(voxels,0)
	chunks=rl.LoadShaderBuffer(size_of(chunkType)*len(world.chunkData),raw_data(world.chunkData[:]))
	rl.BindShaderBuffer(chunks,1)

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
	rl.UpdateShaderBuffer(size_of(voxelType)*len(world.voxelData),raw_data(world.voxelData[:]),voxels)
	rl.BindShaderBuffer(voxels,0)
	rl.UpdateShaderBuffer(size_of(chunkType)*len(world.chunkData),raw_data(world.chunkData[:]),chunks)
	rl.BindShaderBuffer(chunks,1)
	rl.BeginDrawing()
		deltaTime=rl.deltaTime
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
	// rl.rlUnloadShaderBuffer(voxels)
	// rl.UnloadShader(shader)
	rl.DestroyWindow()	
}

