package main

import "core:fmt"
println::fmt.println
// import "core:log"
import "core:mem"

runningScreen:proc()

Main::proc()->(ok:bool){
	runningScreen=gameUpdate

	worldInit()
	// for v in world.voxelData[0]{
	// 	println(v)
	// }
	if !renderInit(800,450,"game") do return
	gameInit()
	for(!quit){
		renderUpdate()
	}
	worldDestroy()
	renderDestroy()
	return true
}

main::proc(){
	// context.logger=log.create_console_logger()

	tracking_allocator:mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator,context.allocator)
	context.allocator=mem.tracking_allocator(&tracking_allocator)
	
	// temp_tracking_allocator:mem.Tracking_Allocator
	// mem.tracking_allocator_init(&temp_tracking_allocator,context.temp_allocator)
	// context.temp_allocator=mem.tracking_allocator(&temp_tracking_allocator)

	reset_tracking_allocator::proc(a:^mem.Tracking_Allocator)->bool{
		leaks:=false
		for _,value in a.allocation_map{
			println(value.location," Leaked ",value.size," bytes")
			leaks=true
		}
		for value in a.bad_free_array{
			println(value.location," : Bad free")
		}
		mem.tracking_allocator_clear(a)
		return leaks
	}

	ok:=Main()

	// if(!reset_tracking_allocator(&temp_tracking_allocator)){println("No Temp Leaks!")}
	// mem.tracking_allocator_destroy(&temp_tracking_allocator)
	if(!reset_tracking_allocator(&tracking_allocator)){println("No Leaks!")}
	mem.tracking_allocator_destroy(&tracking_allocator)
}

