package main

import fl "shared:FolkLibs"
// import vk "vendor:vulkan"

import "core:fmt"
import la "core:math/linalg"

quit:bool
deltaTime:f32
runTime:f32

@(private="file")
pipeline:fl.Pipeline
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
Loc:fl.UBO

last::proc(arr:[dynamic]$T)->^T{
	return &arr[len(arr)-1]
}

Uniforms:struct{
	pos:[3]f32,
	fwd:[3]f32,
	right:[3]f32,
	// up:[3]f32,
	fov:f32,
	runTime:f32,
	resolution:[2]f32,
}

renderInit::proc(width,height:i32,name:cstring)->(ok:bool=true){
	fl.InitWindow(width,height,name) or_return
	defer if !ok{fl.DestroyWindow()}

	Loc=fl.CreateUBO(size_of(Uniforms)) or_return
	// shader=fl.LoadShader("../../shaders/simple.vs","../../shaders/march.fs") or_return
	pipeline=fl.CreateScreenPipeline(string(#load("../build/spv/march.frag.spv")),Loc.descriptorSetLayout) or_return
	// voxels=fl.LoadShaderBuffer(size_of(voxelType)*len(world.voxelData),raw_data(world.voxelData[:]))
	// fl.BindShaderBuffer(voxels,0)
	// chunks=fl.LoadShaderBuffer(size_of(chunkType)*len(world.chunkData),raw_data(world.chunkData[:]))
	// fl.BindShaderBuffer(chunks,1)

	// Loc=fl.GetUniforms(shader,([LocNames]cstring)({
	// 	.pos="pos",
	// 	.fwd="fwd",
	// 	.right="right",
	// 	.fov="fov",
	// 	.runTime="runTime",
	// 	.resolution="resolution",
	// }))
	// fl.SetUniform(Loc[.resolution],fl.resolution)
	return
}

renderUpdate::proc(){
	// fl.UpdateShaderBuffer(size_of(voxelType)*len(world.voxelData),raw_data(world.voxelData[:]),voxels)
	// fl.BindShaderBuffer(voxels,0)
	// fl.UpdateShaderBuffer(size_of(chunkType)*len(world.chunkData),raw_data(world.chunkData[:]),chunks)
	// fl.BindShaderBuffer(chunks,1)
	fl.BeginDrawing({})
		deltaTime=fl.deltaTime
		runTime=fl.runTime
		
		// Uniforms.pos=Cam.pos
		// Uniforms.fwd=Cam.fwd
		// Uniforms.right=Cam.right
		// Uniforms.fov=Cam.fov
		Uniforms.runTime=runTime
		Uniforms.resolution=fl.resolution
		fl.UpdateUniformBuffer(Loc,rawptr(&Uniforms),size_of(Uniforms))
		
		runningScreen()
		
		// fl.ScreenShader(shader)
		fl.BeginShaderMode(pipeline)
		fl.EndShaderMode()
	fl.EndDrawing()
	free_all(context.temp_allocator)
	quit|=fl.quit
}

renderDestroy::proc(){
	// fl.rlUnloadShaderBuffer(voxels)
	// fl.UnloadShader(shader)
	fl.DestroyUBO(Loc)
	fl.DestroyWindow()	
}

