package render

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

runTime:f32
deltaTime:f32
bgColor:[3]f32={0.2,0.3,0.3}
resolution:[2]f32
quit:bool

@(private="file")
VAO,VBO:u32
@(private="file")
resolutionLoc:i32

@(private)
window:glfw.WindowHandle

GL_MAJOR_VERSION::4
GL_MINOR_VERSION::3

InitWindow::proc(width,height:i32,name:cstring)->(ok:bool=true){
	glfw.WindowHint(glfw.RESIZABLE,1)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR,GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR,GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE,glfw.OPENGL_CORE_PROFILE)
	
	if(glfw.Init()!=true){
		fmt.println("Failed to initialize GLFW")
		return false
	}
	defer if !ok{glfw.Terminate()}

	window=glfw.CreateWindow(width,height,name,nil,nil)
	if window==nil {
		fmt.println("Unable to create window")
		return false
	}
	defer if !ok{glfw.DestroyWindow(window)}
    resolution={f32(width),f32(height)}
	
	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)
	gl.load_up_to(int(GL_MAJOR_VERSION),GL_MINOR_VERSION,glfw.gl_set_proc_address)
	VAO,VBO=ScreenVerts()
	
	glfw.SetKeyCallback(window,key_callback)
	glfw.SetCursorPosCallback(window,mouse_callback)
	glfw.SetFramebufferSizeCallback(window,size_callback)
	
	resolution=[2]f32{f32(width),f32(height)}
	
	return true
}

DestroyWindow::proc(){
	glfw.DestroyWindow(window)
	glfw.Terminate()
}

LoadShader::proc($vspath:string,$fspath:string)->(shader:u32,ok:bool=true){
	vs:=string(#load(vspath))
	fs:=string(#load(fspath))
	
	shader,ok=gl.load_shaders_source(vs,fs);
	if !ok{
		fmt.println("ERROR: Failed to load and compile shaders.")
		return
	}
	return
}

ScreenVerts::proc()->(VAO,VBO:u32){
	vertices:=[?]f32{
		-1,-1,
		 1,-1,
		-1, 1,
		 1, 1,
	}
	
	gl.GenVertexArrays(1,&VAO)
	gl.BindVertexArray(VAO)
	
	gl.GenBuffers(1,&VBO)
	gl.BindBuffer(gl.ARRAY_BUFFER,VBO)
	
	gl.BufferData(gl.ARRAY_BUFFER,size_of(vertices),&vertices,gl.STATIC_DRAW)
	
	gl.VertexAttribPointer(0,2,gl.FLOAT,gl.FALSE,2*size_of(f32),0)
	gl.EnableVertexAttribArray(0)
	
	gl.BindBuffer(gl.ARRAY_BUFFER,0)
	return
}

LoadShaderBuffer::proc(size:int,data:rawptr,flags:u32=gl.STREAM_COPY)->(buffer:u32){
	gl.GenBuffers(1,&buffer);
	gl.BindBuffer(gl.SHADER_STORAGE_BUFFER,buffer);
	gl.BufferData(gl.SHADER_STORAGE_BUFFER,size,data,flags);
	gl.BindBuffer(gl.SHADER_STORAGE_BUFFER,0);
	return
}

UpdateShaderBuffer::proc(size:int,data:rawptr,buffer:u32,flags:u32=gl.STREAM_COPY){
	gl.BindBuffer(gl.SHADER_STORAGE_BUFFER,buffer);
	gl.BufferData(gl.SHADER_STORAGE_BUFFER,size,data,flags);
	gl.BindBuffer(gl.SHADER_STORAGE_BUFFER,0);
	return
}

BindShaderBuffer::proc(buffer:u32,index:u32){
	gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER,index,buffer)
}

ScreenShader::proc(shader:u32){
	gl.UseProgram(shader)
	gl.BindVertexArray(VAO)
	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)
}

BeginDrawing::proc(){
	glfw.PollEvents()
	time:=f32(glfw.GetTime())
	deltaTime=time-runTime
	runTime=time
	gl.ClearColor(bgColor.r,bgColor.g,bgColor.b,1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

EndDrawing::proc(){
	inputUpdate()
	glfw.SwapBuffers(window)
	quit|=bool(glfw.WindowShouldClose(window))
}

GetUniforms::proc(shader:u32,names:[$N]cstring)->(uniforms:[N]i32){
	for i in N{
		uniforms[i]=gl.GetUniformLocation(shader,names[i])
	}
	return
}

SetUniformv3::proc(uniform:i32,valueIn:[3]f32){
	value:=valueIn
	gl.Uniform3fv(uniform,1,raw_data(value[:]))
}
SetUniformv2::proc(uniform:i32,valueIn:[2]f32){
	value:=valueIn
	gl.Uniform2fv(uniform,1,raw_data(value[:]))
}
SetUniformf::proc(uniform:i32,value:f32){
	gl.Uniform1f(uniform,value)
}
SetUniform::proc{SetUniformv3,SetUniformv2,SetUniformf}

size_callback::proc"c"(window:glfw.WindowHandle,width,height:i32){
    // context = runtime.default_context()
	gl.Viewport(0,0,width,height)
	resolution={f32(width),f32(height)}
}

