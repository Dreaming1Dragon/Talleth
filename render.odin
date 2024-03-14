package main

import rl "RenderLib"

import "core:fmt"
import la "core:math/linalg"

quit:bool
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
@(private="file")
voxelData:struct{
	voxels:[2][16*16*16]f32
}
@(private="file")
chunkData:struct{
	chunks:[2]struct{
		neighbors:[6]u32,
		vox:u32,
	}
}
@(private="file")
none:=transmute(u32)i32(-1)

renderInit::proc(width,height:i32,name:cstring)->(ok:bool=true){
	rl.InitWindow(width,height,name) or_return
	defer if !ok{rl.DestroyWindow()}

	shader=rl.LoadShader("../shaders/simple.vs","../shaders/march.fs") or_return
	for i in 0..<2{
		for x in 0..<16{
			for y in 0..<16{
				for z in 0..<16{
					dst:=la.length([3]f32{f32(x),f32(y),f32(z)}-8)
					voxelData.voxels[i][x+y*16+z*16*16]=dst-(2*f32(i+1))
					// fmt.println(x,y,z,dst)
				}
			}
		}
	}
	voxels=rl.LoadShaderBuffer(size_of(voxelData),&voxelData)
	rl.BindShaderBuffer(voxels,0)
	chunkData={{{
		neighbors={
			1   ,none,
			none,none,
			none,none,
		},
		vox=0,
	},{
		neighbors={
			none,0,
			none,none,
			none,none,
		},
		vox=1,
	}}}
	chunks=rl.LoadShaderBuffer(size_of(chunkData),&chunkData)
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
	// rl.rlUnloadShaderBuffer(voxels)
	// rl.UnloadShader(shader)
	rl.DestroyWindow()	
}

