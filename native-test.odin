package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"


main :: proc() {
	wh := wl.init()
	fmt.println(wh)
	// wl.bind_interfaces({"wl_compositor"})
	// wl.roundtrip()
}
