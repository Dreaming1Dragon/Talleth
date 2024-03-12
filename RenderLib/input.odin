package render

import "core:fmt"
import "vendor:glfw"
import "core:runtime"

KeyBind::struct{
	set:bool,
	hold:bool,
	code:i32
}

input:struct{
	keys:[]KeyBind,
	mouse:[2]f32
}

@(private="file")
mouseCaptured:bool
@(private="file")
mousePos:[2]f32

CaptureCursor::proc(){
	// rl.DisableCursor()
	glfw.SetInputMode(window,glfw.CURSOR,glfw.CURSOR_DISABLED)
	mouseCaptured=true
}

ReleaseCursor::proc(){
	// rl.EnableCursor()
	glfw.SetInputMode(window,glfw.CURSOR,glfw.CURSOR_NORMAL)
	mouseCaptured=false
}

GetKey::proc($KEY)->u32{
	return glfw.KEY
}

inputInit::proc(keys:[]KeyBind){
	input.keys=keys
	// input.keys[.fwd]={hold=true,code=glfw.KEY_W}
	// input.keys[.back]={hold=true,code=glfw.KEY_S}
	// input.keys[.right]={hold=true,code=glfw.KEY_D}
	// input.keys[.left]={hold=true,code=glfw.KEY_A}
	// input.keys[.jump]={hold=true,code=glfw.KEY_SPACE}
	// input.keys[.crouch]={hold=true,code=glfw.KEY_LEFT_SHIFT}
	// input.keys[.pause]={hold=false,code=glfw.KEY_ESCAPE}
}

key_callback::proc"c"(window:glfw.WindowHandle,key,scancode,action,mods:i32){
	// context = runtime.default_context()
	for k in &input.keys{
		if(k.code==key){
			if(action==glfw.PRESS){
				k.set=true
			}else if(action==glfw.RELEASE){
				k.set=false
			}
		}
	}
}

mouse_callback::proc"c"(window:glfw.WindowHandle,xpos,ypos:f64){
	pos:[2]f32={f32(xpos),resolution.y-f32(ypos)}
	if mouseCaptured{
		input.mouse=pos-mousePos
	}else{
		input.mouse=pos
	}
	mousePos=pos
}

inputUpdate::proc(){
	for k,i in &input.keys{
		if !k.hold{
			k.set=false
		}
	}
	if mouseCaptured{
		input.mouse={0,0}
	}
	// for i in controls{
	// 	if(input.keys[i].hold){
	// 		input.keys[i].set=rl.IsKeyDown(input.keys[i].code)
	// 	}else{
	// 		input.keys[i].set=rl.IsKeyPressed(input.keys[i].code)
	// 	}
	// }
	// input.mouse=mouseCaptured?rl.GetMouseDelta():rl.GetMousePosition()
	// input.mouse=rl.GetMouseDelta()
}

// inputDestroy::proc(){
	
// }

