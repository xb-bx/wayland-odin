package main

import "core:c"
import "core:fmt"
import wl "wayland"

WL_DISPLAY_GET_REGISTRY :: 1

global :: proc(
	data: rawptr,
	registry: ^wl.wl_registry,
	name: c.uint32_t,
	interface: cstring,
	version: c.uint32_t,
) {
	fmt.println(interface)
}

global_remove :: proc(data: rawptr, registry: ^wl.wl_registry, name: c.uint32_t) {
}

main :: proc() {
	display := wl.display_connect(nil)
	fmt.println(display)

	registry := wl.wl_display_get_registry(display)

	fmt.println(display)
	fmt.println(registry)


	listener := wl.wl_registry_listener {
		global        = global,
		global_remove = global_remove,
	}

	wl.wl_registry_add_listener(registry, &listener, nil)

	x := wl.display_roundtrip(display)
	fmt.println(x)
}
