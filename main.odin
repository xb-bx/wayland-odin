package main

import "core:c"
import "core:fmt"
import wl "wayland"


state :: struct {
	compositor: ^wl.wl_compositor,
	xdg_base:   ^wl.xdg_wm_base,
	shm:        ^wl.wl_shm,
	surface:    ^wl.wl_surface,
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
		state.compositor =
		cast(^wl.wl_compositor)(wl.wl_registry_bind(
				registry,
				name,
				&wl.wl_compositor_interface,
				version,
			))
	}

	if interface == wl.wl_shm_interface.name {
		state: ^state = cast(^state)data
		state.shm =
		cast(^wl.wl_shm)(wl.wl_registry_bind(registry, name, &wl.wl_shm_interface, version))
	}

	if interface == wl.xdg_wm_base_interface.name {
		state: ^state = cast(^state)data
		state.xdg_base =
		cast(^wl.xdg_wm_base)(wl.wl_registry_bind(
				registry,
				name,
				&wl.xdg_wm_base_interface,
				version,
			))
	}
	// fmt.println(interface)
}

global_remove :: proc(data: rawptr, registry: ^wl.wl_registry, name: c.uint32_t) {
}

registry_listener := wl.wl_registry_listener {
	global        = global,
	global_remove = global_remove,
}

surface_listener := wl.xdg_surface_listener {
	configure = surface_configure,
}

surface_configure :: proc(data: rawptr, surface: ^wl.xdg_surface, serial: c.uint32_t) {
	fmt.println("surface configure")
	wl.xdg_surface_ack_configure(surface, serial)
}


main :: proc() {
	state: state = {}

	display := wl.display_connect(nil)
	registry := wl.wl_display_get_registry(display)

	registry_listener := wl.wl_registry_listener {
		global        = global,
		global_remove = global_remove,
	}

	wl.wl_registry_add_listener(registry, &registry_listener, &state)
	x := wl.display_roundtrip(display)

	// fmt.println(x)

	// Only after first round trip state.compositor is set
	state.surface = wl.wl_compositor_create_surface(state.compositor)

	xdg_surface := wl.xdg_wm_base_get_xdg_surface(state.xdg_base, state.surface)
	wl.xdg_surface_add_listener(xdg_surface, &surface_listener, &state)

	fmt.println(state)
	wl.display_dispatch(display)
}
