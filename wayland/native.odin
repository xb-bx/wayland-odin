package wayland

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import "core:strings"

InterfaceMap :: map[string]WlInterface

WlHandle :: struct {
	display:    ^WlDisplay,
	queue:      queue.Queue(WlEvent),
	interfaces: InterfaceMap,
}


Wl_Base_Interface :: struct {
	proxy:     ^wl_proxy,
	interface: ^wl_interface,
}

WlInterface :: union {
	WlRegistry,
}


@(private)
wh: WlHandle = {}

init :: proc() {
	d := display_connect(nil)
	fmt.printf("original display pointer %p\n", d)
	// Manualy configure a display interface object
	wh.display = create_wl_display(cast(^wl_proxy)d)
	wh.interfaces[WL_INTERFACE_WL_REGISTRY] = wh.display->get_registry()
	tmp := (wh.interfaces[WL_INTERFACE_WL_REGISTRY]).(WlRegistry)
	fmt.println(tmp.proxy)
}

poll :: proc() -> []WlEvent {
	roundtrip()
	result: [dynamic]WlEvent

	for {
		event, ok := queue.pop_front_safe(&wh.queue)
		if !ok {
			break
		}
		append(&result, event)
	}
	return result[:]
}

roundtrip :: proc "contextless" () {
	display_roundtrip(cast(^wl_display)wh.display.proxy)
}


interface :: proc(name: string, $T: typeid) -> ^T {
	iface := wh.interfaces[name]

	return cast(^T)iface
}

bind_interfaces :: proc(interface_names: []string) {
	registry := (wh.interfaces["wl_registry"]).(WlRegistry)
	for event in poll() {
		#partial switch e in event {
		case WlRegistryGlobal:
			for iname in interface_names {
				fmt.println(e.interface)
				if string(e.interface) == iname {
					proxy := cast(^wl_proxy)registry->bind(
						e.name,
						&wl_compositor_interface,
						e.version,
					)
					fmt.println("not working", registry.proxy)
					fmt.println("working", e.registry)
					// proxy := wl_registry_bind(
					// 	cast(^wl_registry)e.registry,
					// 	e.name,
					// 	&wl_compositor_interface,
					// 	e.version,
					// )
					_ = proxy

					// wh.interfaces[WL_INTERFACE_WL_COMPOSITOR] = create_wl_compositor(proxy)
				}
			}
		}
	}
}

// Wl_Display :: struct {
// 	using base:   Wl_Base_Interface,
// 	get_registry: proc "c" (_wl_display: ^Wl_Display) -> ^Wl_Registry,
// }

// _wl_display_get_registry :: proc "c" (_wl_display: ^Wl_Display) -> ^Wl_Registry {
// 	display: ^wl_proxy = _wl_display.proxy
// 	registry: ^wl_proxy
// 	registry = proxy_marshal_flags(
// 		display,
// 		1,
// 		&wl_registry_interface,
// 		proxy_get_version(display),
// 		0,
// 		nil,
// 	)

// 	return create_wl_registry(registry)
// }

// WL_INTERFACE_WL_REGISTRY: string = "wl_registry"

// Wl_Registry :: struct {
// 	using base: Wl_Base_Interface,
// 	bind:       proc "c" (
// 		_: ^Wl_Registry,
// 		name: c.uint32_t,
// 		interface: ^wl_interface,
// 		version: c.uint32_t,
// 	) -> rawptr,
// 	destroy:    proc "c" (wl_registry: ^wl_registry),
// }

// Wl_Registry_Global :: struct {
// 	data:      rawptr,
// 	registry:  ^wl_registry,
// 	name:      c.uint32_t,
// 	interface: string,
// 	version:   c.uint32_t,
// }

// Wl_Registry_Global_Remove :: struct {
// 	data:     rawptr,
// 	registry: ^wl_registry,
// 	name:     c.uint32_t,
// }


// create_wl_registry :: proc "contextless" (_wl_registry: ^wl_proxy) -> ^Wl_Registry {
// 	context = runtime.default_context()
// 	registry_listener := wl_registry_listener {
// 		global = proc "c" (
// 			data: rawptr,
// 			registry: ^wl_registry,
// 			name: c.uint32_t,
// 			interface: cstring,
// 			version: c.uint32_t,
// 		) {
// 			context = runtime.default_context()
// 			queue.enqueue(
// 				&wh.queue,
// 				Wl_Registry_Global {
// 					data,
// 					registry,
// 					name,
// 					strings.clone_from_cstring(interface),
// 					version,
// 				},
// 			)
// 		},
// 		global_remove = proc "c" (data: rawptr, registry: ^wl_registry, name: c.uint32_t) {
// 			context = runtime.default_context()
// 			queue.enqueue(&wh.queue, Wl_Registry_Global_Remove{data, registry, name})
// 		},
// 	}

// 	wl_registry_bind :: proc "c" (
// 		registry: ^Wl_Registry,
// 		name: c.uint32_t,
// 		interface: ^wl_interface,
// 		version: c.uint32_t,
// 	) -> rawptr {
// 		id: ^wl_proxy
// 		id = proxy_marshal_flags(
// 			registry.proxy,
// 			0,
// 			interface,
// 			version,
// 			0,
// 			name,
// 			interface.name,
// 			version,
// 			nil,
// 		)


// 		return cast(rawptr)id
// 	}


// 	wl_registry_destroy :: proc "c" (wl_registry: ^wl_registry) {
// 		proxy_destroy(cast(^wl_proxy)wl_registry)
// 	}

// 	proxy_add_listener(_wl_registry, cast(^Implementation)&registry_listener, nil)
// 	roundtrip()

// 	res := new(Wl_Registry)
// 	res.proxy = _wl_registry
// 	res.interface = &wl_registry_interface
// 	res.bind = wl_registry_bind
// 	res.destroy = wl_registry_destroy

// 	return res
// }

// WL_INTERFACE_WL_COMPOSITOR: string = "wl_compositor"

// create_wl_compositor :: proc "contextless" (_wl_compositor: ^wl_proxy) -> ^Wl_Compositor {
// 	context = runtime.default_context()
// 	listener := wl_compositor_listener{}

// 	proxy_add_listener(_wl_compositor, cast(^Implementation)&listener, nil)

// 	wl_compositor_create_surface :: proc "c" (compositor: ^Wl_Compositor) -> ^wl_surface {

// 		id: ^wl_proxy
// 		id = proxy_marshal_flags(
// 			compositor.proxy,
// 			0,
// 			&wl_surface_interface,
// 			proxy_get_version(compositor.proxy),
// 			0,
// 			nil,
// 		)
// 		return cast(^wl_surface)id
// 	}

// 	wl_compositor_create_region :: proc "c" (compositor: ^Wl_Compositor) -> ^wl_region {
// 		id: ^wl_proxy
// 		id = proxy_marshal_flags(
// 			compositor.proxy,
// 			1,
// 			&wl_region_interface,
// 			proxy_get_version(compositor.proxy),
// 			0,
// 			nil,
// 		)
// 		return cast(^wl_region)id
// 	}

// 	res := new(Wl_Compositor)
// 	res.proxy = _wl_compositor
// 	res.interface = &wl_compositor_interface
// 	res.create_surface = wl_compositor_create_surface
// 	res.create_region = wl_compositor_create_region
// 	return res
// }

// Wl_Compositor :: struct {
// 	using base:     Wl_Base_Interface,
// 	create_surface: proc "c" (compositor: ^Wl_Compositor) -> ^wl_surface,
// 	create_region:  proc "c" (compositor: ^Wl_Compositor) -> ^wl_region,
// }
