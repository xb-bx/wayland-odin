package wayland

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import "core:strings"

Wl_Handle :: struct {
	display: Wl_Display,
	queue:   queue.Queue(Wl_Event),
}

Wl_Event :: union {
	Wl_Registry_Global,
	Wl_Registry_Global_Remove,
}

Wl_Base_Interface :: struct {
	proxy:     ^wl_proxy,
	interface: ^wl_interface,
}

Wl_Display :: struct {
	using base:   Wl_Base_Interface,
	// proxy:        ^wl_proxy,
	// interface:    ^wl_interface,
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
	interface: string,
	version:   c.uint32_t,
}

Wl_Registry_Global_Remove :: struct {
	data:     rawptr,
	registry: ^wl_registry,
	name:     c.uint32_t,
}

@(private)
wh: Wl_Handle = {}

init :: proc() {
	d := display_connect(nil)
	fmt.printf("original display pointer %p\n", d)
	// Manualy configure a display interface object
	wh.display = Wl_Display {
		proxy        = cast(^wl_proxy)d,
		interface    = &wl_display_interface,
		get_registry = _wl_display_get_registry,
	}


	wh.display->get_registry()
}

poll :: proc() -> []Wl_Event {
	result: [dynamic]Wl_Event

	for {
		event, ok := queue.pop_front_safe(&wh.queue)
		if !ok {
			break
		}
		append(&result, event)
	}
	return result[:]
}

roundtrip :: proc() {
	display_roundtrip(cast(^wl_display)wh.display.proxy)
}


bind_interfaces :: proc(interface_names: []string) {
	for event in poll() {
		#partial switch e in event {
		case Wl_Registry_Global:
			for iname in interface_names {
				if string(e.interface) == iname {
					fmt.println(e.interface)
				}
			}
		}
	}
}

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
	context = runtime.default_context()
	registry_listener := wl_registry_listener {
		global = proc "c" (
			data: rawptr,
			registry: ^wl_registry,
			name: c.uint32_t,
			interface: cstring,
			version: c.uint32_t,
		) {
			context = runtime.default_context()
			queue.enqueue(
				&wh.queue,
				Wl_Registry_Global {
					data,
					registry,
					name,
					strings.clone_from_cstring(interface),
					version,
				},
			)
		},
		global_remove = proc "c" (data: rawptr, registry: ^wl_registry, name: c.uint32_t) {
			context = runtime.default_context()
			queue.enqueue(&wh.queue, Wl_Registry_Global_Remove{data, registry, name})
		},
	}

	wl_registry_bind :: proc "c" (
		_wl_registry: ^wl_registry,
		name: c.uint32_t,
		interface: ^wl_interface,
		version: c.uint32_t,
	) -> rawptr {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			cast(^wl_proxy)_wl_registry,
			0,
			interface,
			version,
			0,
			name,
			interface.name,
			version,
			nil,
		)


		return cast(rawptr)id
	}


	wl_registry_destroy :: proc "c" (wl_registry: ^wl_registry) {
		proxy_destroy(cast(^wl_proxy)wl_registry)
	}

	proxy_add_listener(registry, cast(^Implementation)&registry_listener, nil)
	roundtrip()

	return Wl_Registry{proxy = registry, interface = &wl_registry_interface}
}
