package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"


main :: proc() {
	wl.init()
	wl.bind_interfaces({"wl_compositor"})

	// for event in wl.poll() {
	// 	fmt.println(event)
	// }

	// compositor := wl.interface("wl_compositor", wl.Wl_Compositor)

	// fmt.println(compositor)
	// fmt.printf("%p\n", compositor->create_surface())


	// wl.bind_interfaces({"wl_compositor", "xdg_wm_base", "wl_seat"})

	// compositor := wl.interface("wl_compositor")
	// base := wl.interface("xdg_wm_base")
	// surface := compositor->create_surface()
	// xdg_surface := base->get_xdg_surface(surface)
	// toplevel := base->get_toplevel_surface(xdg_surface)

	// for {
	// 	for event in wl.poll() {
	// 		#partial switch e in event {
	// 		case Cenas:
	// 			fmt.println("cenas")
	// 		}
	// 	}
	// }
}
