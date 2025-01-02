package main

import "core:c"
import "core:fmt"
import wl "wayland"

WL_DISPLAY_GET_REGISTRY :: 1

wl_registry_listener :: struct {
	global:        proc(_: rawptr, _: ^wl.wl_registry, _: c.uint32_t, _: cstring, _: c.uint32_t),
	global_remove: proc(_: rawptr, _: ^wl.wl_registry, _: c.uint32_t),
}

wl_display_get_registry :: proc(display: ^wl.wl_display) -> ^wl.wl_registry {
	registry: ^wl.wl_proxy = wl.proxy_marshal_flags(
		cast(^wl.wl_proxy)display,
		WL_DISPLAY_GET_REGISTRY,
		&wl.wl_registry_interface,
		wl.proxy_get_version(cast(^wl.wl_proxy)display),
		0,
		nil,
	)
	return auto_cast registry
}

wl_registry_add_listener :: proc(
	wl_registry: ^wl.wl_registry,
	listener: ^wl_registry_listener,
	data: rawptr,
) -> c.int {

	return wl.proxy_add_listener(cast(^wl.wl_proxy)wl_registry, auto_cast listener, data)
}


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

	registry := wl_display_get_registry(display)

	fmt.println(display)
	fmt.println(registry)


	listener := wl_registry_listener {
		global        = global,
		global_remove = global_remove,
	}

	wl_registry_add_listener(registry, &listener, nil)

	x := wl.display_roundtrip(display)
	fmt.println(x)
}
