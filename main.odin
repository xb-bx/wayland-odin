package main

import "core:c"
import "core:fmt"
import wl "wayland"


message :: struct {
	next: ^message,
}

global :: proc(
	data: rawptr,
	registry: ^wl.wl_registry,
	name: c.uint32_t,
	interface: cstring,
	version: c.uint32_t,
) {
	if interface == wl.wl_compositor_interface.name {
		state: ^state = cast(^state)data
		state.compositor = nil
		state.compositor =
		cast(^wl.wl_compositor)(wl.wl_registry_bind(
				registry,
				name,
				&wl.wl_compositor_interface,
				version,
			))
	}
	fmt.println(interface)
}

global_remove :: proc(data: rawptr, registry: ^wl.wl_registry, name: c.uint32_t) {
}

state :: struct {
	compositor: ^wl.wl_compositor,
}

main :: proc() {
	state: state = {}

	display := wl.display_connect(nil)
	fmt.println(display)

	registry := wl.wl_display_get_registry(display)

	fmt.println(display)
	fmt.println(registry)


	registry_listener := wl.wl_registry_listener {
		global        = global,
		global_remove = global_remove,
	}

	wl.wl_registry_add_listener(registry, &registry_listener, &state)

	x := wl.display_roundtrip(display)
	fmt.println(x)
	fmt.println(state)
}
