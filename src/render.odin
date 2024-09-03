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
// @(private="file")
// Loc:fl.UBO

last::proc(arr:[dynamic]$T)->^T{
	return &arr[len(arr)-1]
}

// Uniforms:struct{
// 	resolution:[2]f32,
// 	pos:[3]f32,
// 	fwd:[3]f32,
// 	right:[3]f32,
// 	// up:[3]f32,
// 	fov:f32,
// 	runTime:f32,
// }
Uniforms:struct{
	pos:[3]f32,
	pad:f32,
	fwd:[3]f32,
	pad2:f32,
	right:[3]f32,
	fov:f32,
	runTime:f32,
	pad3:f32,
	resolution:[2]f32,
}

renderInit::proc(width,height:i32,name:cstring)->(ok:bool=true){
	fl.InitWindow(width,height,name) or_return
	defer if !ok do fl.DestroyWindow()
	// println(fl.resolution)
	
	fl.MakeUBO(&pipeline,size_of(Uniforms),0)
	defer if !ok do fl.DestroyBuffers(pipeline)
	fl.MakeSSBO(&pipeline,size_of(voxelType)*len(world.voxelData),1)
	// defer if !ok do fl.DestroySSBO(pipeline)
	fl.MakeSSBO(&pipeline,size_of(chunkType)*len(world.chunkData),2)
	// defer if !ok do fl.DestroySSBO(pipeline)
	fl.MakeScreenPipeline(&pipeline,string(#load("../build/spv/march.frag.spv"))) or_return
	defer if !ok do fl.DestroyShader(pipeline)

	// Loc=fl.CreateUBO(size_of(Uniforms)) or_return
	// shader=fl.LoadShader("../../shaders/simple.vs","../../shaders/march.fs") or_return
	// pipeline=fl.CreateScreenPipeline(string(#load("../build/spv/march.frag.spv")),Loc.descriptorSetLayout) or_return
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
	// fl.inputUpdate()
	Uniforms.pos=Cam.pos
	Uniforms.fwd=Cam.fwd
	Uniforms.right=Cam.right
	Uniforms.fov=Cam.fov
	
	fl.BeginDrawing({0,0,0,1})
		deltaTime=fl.deltaTime
		runTime=fl.runTime
		runningScreen()
		
		Uniforms.runTime=runTime
		Uniforms.resolution=fl.resolution
		fl.UpdateBuffer(&pipeline,0,rawptr(&Uniforms),size_of(Uniforms))
		fl.UpdateBuffer(&pipeline,1,rawptr(&world.voxelData[0]),size_of(voxelType)*len(world.voxelData))
		fl.UpdateBuffer(&pipeline,2,rawptr(&world.chunkData[0]),size_of(chunkType)*len(world.chunkData))
		
		// fl.ScreenShader(shader)
		fl.BeginShaderMode(&pipeline)
		fl.EndShaderMode()
	fl.EndDrawing()
	free_all(context.temp_allocator)
	quit|=fl.quit
}

renderDestroy::proc(){
	// fl.rlUnloadShaderBuffer(voxels)
	// fl.UnloadShader(shader)
	// fl.DestroyUBO(Loc)
	fl.DestroyBuffers(pipeline)
	fl.DestroyShader(pipeline)
	fl.DestroyWindow()	
}

