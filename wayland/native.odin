package wayland

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"

Wl_Handle :: struct {
	display: Wl_Display,
	// registry: ^wl_registry,
	queue:   queue.Queue(Wl_Event),
}

Wl_Event :: union {
	Wl_Registry_Global,
	Wl_Registry_Global_Remove,
}

Wl_Base_Interface :: struct {
	// proxy:     ^wl_proxy,
	// interface: ^wl_interface,
}

Wl_Display :: struct {
	proxy:        ^wl_proxy,
	interface:    ^wl_interface,
	get_registry: proc "c" (_wl_display: ^Wl_Display) -> Wl_Registry,
}

Wl_Registry :: struct {
	// using base: Wl_Base_Interface,
	proxy:     ^wl_proxy,
	interface: ^wl_interface,
}

Wl_Registry_Global :: struct {
	data:      rawptr,
	registry:  ^wl_registry,
	name:      c.uint32_t,
	interface: cstring,
	version:   c.uint32_t,
}

Wl_Registry_Global_Remove :: struct {}

init :: proc() -> Wl_Handle {
	d := display_connect(nil)
	fmt.printf("original display pointer %p\n", d)
	// Manualy configure a display interface object
	display := Wl_Display {
		proxy        = cast(^wl_proxy)d,
		interface    = &wl_display_interface,
		get_registry = _wl_display_get_registry,
	}

	display->get_registry()

	return Wl_Handle{display = display}
	// _way.display = display
}

poll :: proc() -> []Wl_Event {
	result: [dynamic]Wl_Event

	// for {
	// 	event, ok := queue.pop_front_safe(&_way.queue)
	// 	fmt.println("---", event)
	// 	if !ok {
	// 		break
	// 	}
	// 	append(&result, event)
	// }
	for event in q {
		fmt.println(event)
		append(&result, event)
	}

	return result[:]
}

// roundtrip :: proc() {
// 	fmt.printf("Pre cast pointer: %p\n", _way.display.proxy)
// 	fmt.printf("casted pointer: %p\n", cast(^wl_display)_way.display.proxy)
// 	display_roundtrip(cast(^wl_display)_way.display.proxy)
// }


bind_interfaces :: proc(wh: ^Wl_Handle, interface_names: []string) {
	// roundtrip()
	// for event in poll() {
	// 	fmt.println("###", event)
	// 	// #partial switch e in event {
	// 	// case Wl_Registry_Global:
	// 	// 	for iname in interface_names {
	// 	// 		// if string(e.interface) == iname {
	// 	// 		fmt.println(e.interface)
	// 	// 		// }
	// 	// 	}
	// 	// }
	// }
}

q: [100]Wl_Event
qi: u32 = 0

_wl_display_get_registry :: proc "c" (_wl_display: ^Wl_Display) -> Wl_Registry {
	display: ^wl_proxy = _wl_display.proxy
	registry: ^wl_proxy
	registry = proxy_marshal_flags(
		display,
		1,
		&wl_registry_interface,
		proxy_get_version(display),
		0,
		nil,
	)
	// context = runtime.default_context()
	registry_listener := wl_registry_listener {
		global = proc "c" (
			data: rawptr,
			registry: ^wl_registry,
			name: c.uint32_t,
			interface: cstring,
			version: c.uint32_t,
		) {
			context = runtime.default_context()
			// fmt.println("fooo")
			// fmt.println(Wl_Registry_Global{data, registry, name, interface, version})
			// queue.enqueue(&way.queue, Wl_Registry_Global{data, registry, name, interface, version})
			// append(&q, Wl_Registry_Global{data, registry, name, interface, version})
			q[qi] = Wl_Registry_Global{data, registry, name, interface, version}
			qi += 1
			// fmt.println(queue.pop_back_safe(&way.queue))
		},
		global_remove = proc "c" (data: rawptr, wl_registry: ^wl_registry, name: c.uint32_t) {},
	}
	proxy_add_listener(registry, cast(^Implementation)&registry_listener, nil)
	display_roundtrip(cast(^wl_display)_wl_display.proxy)
	return Wl_Registry{proxy = registry, interface = &wl_registry_interface}
}
