package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"


main :: proc() {
	wl.init()
	// wl.bind_interfaces({"wl_compositor"})

	// compositor := wl.interface("wl_compositor", wl.Wl_Compositor)

	// fmt.println(compositor)
	// fmt.printf("%p\n", compositor->create_surface())
}
