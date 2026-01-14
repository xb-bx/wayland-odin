package wayland
import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import "core:strings"

WL_INTERFACE_WL_DISPLAY :: "wl_display"

WlDisplay :: struct {
	using base:   ^Wl_Base_Interface,
	sync:         proc "c" (self: ^WlDisplay) -> ^WlCallback,
	get_registry: proc "c" (self: ^WlDisplay) -> WlRegistry,
}

create_wl_display :: proc "contextless" (proxy: ^wl_proxy) -> ^WlDisplay {
	context = runtime.default_context()
	listener := wl_display_listener {
		error = proc "c" (
			data: rawptr,
			wl_display: ^wl_display,
			object_id: rawptr,
			code: c.uint32_t,
			message: cstring,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDisplayError{object_id, code, message})
		},
		delete_id = proc "c" (data: rawptr, wl_display: ^wl_display, id: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDisplayDeleteId{id})
		},
	}

	sync := proc "c" (self: ^WlDisplay) -> ^WlCallback {
		callback: ^wl_proxy
		callback = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_callback_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_callback(callback)
	}

	get_registry := proc "c" (self: ^WlDisplay) -> WlRegistry {
		context = runtime.default_context()
		registry: ^wl_proxy
		registry = proxy_marshal_flags(
			self.proxy,
			1,
			&wl_registry_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)

		fmt.println("---------", registry)

		return create_wl_registry(registry)
	}

	res := new(WlDisplay)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_display_interface

	res.sync = sync
	res.get_registry = get_registry
	return res
}

WlDisplayError :: struct {
	object_id: rawptr,
	code:      c.uint32_t,
	message:   cstring,
}
WlDisplayDeleteId :: struct {
	id: c.uint32_t,
}

WL_INTERFACE_WL_REGISTRY :: "wl_registry"

WlRegistry :: struct {
	using base: ^Wl_Base_Interface,
	bind:       proc "c" (
		self: ^WlRegistry,
		name: c.uint32_t,
		interface: ^wl_interface,
		version: c.uint32_t,
	) -> rawptr,
}

create_wl_registry :: proc "contextless" (proxy: ^wl_proxy) -> WlRegistry {
	context = runtime.default_context()
	listener := wl_registry_listener {
		global = proc "c" (
			data: rawptr,
			wl_registry: ^wl_registry,
			name: c.uint32_t,
			interface: cstring,
			version: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(
				&wh.queue,
				WlRegistryGlobal {
					cast(^wl_proxy)wl_registry,
					name,
					strings.clone_from_cstring(interface),
					version,
				},
			)
		},
		global_remove = proc "c" (data: rawptr, wl_registry: ^wl_registry, name: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlRegistryGlobalRemove{name})
		},
	}

	bind := proc "c" (
		self: ^WlRegistry,
		name: c.uint32_t,
		interface: ^wl_interface,
		version: c.uint32_t,
	) -> rawptr {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
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

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlRegistry)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_registry_interface

	res.bind = bind
	fmt.println("##########", res.base.proxy)
	return res^
}

WlRegistryGlobal :: struct {
	registry:  ^wl_proxy,
	name:      c.uint32_t,
	interface: string,
	version:   c.uint32_t,
}
WlRegistryGlobalRemove :: struct {
	name: c.uint32_t,
}

WL_INTERFACE_WL_CALLBACK :: "wl_callback"

WlCallback :: struct {
	using base: ^Wl_Base_Interface,
}

create_wl_callback :: proc "contextless" (proxy: ^wl_proxy) -> ^WlCallback {
	context = runtime.default_context()
	listener := wl_callback_listener {
		done = proc "c" (data: rawptr, wl_callback: ^wl_callback, callback_data: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlCallbackDone{callback_data})
		},
	}


	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlCallback)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_callback_interface

	return res
}

WlCallbackDone :: struct {
	callback_data: c.uint32_t,
}

WL_INTERFACE_WL_COMPOSITOR :: "wl_compositor"

WlCompositor :: struct {
	using base:     ^Wl_Base_Interface,
	create_surface: proc "c" (self: ^WlCompositor) -> ^WlSurface,
	create_region:  proc "c" (self: ^WlCompositor) -> ^WlRegion,
}

create_wl_compositor :: proc "contextless" (proxy: ^wl_proxy) -> ^WlCompositor {
	context = runtime.default_context()
	listener := wl_compositor_listener{}

	create_surface := proc "c" (self: ^WlCompositor) -> ^WlSurface {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_surface_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_surface(id)

	}
	create_region := proc "c" (self: ^WlCompositor) -> ^WlRegion {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			1,
			&wl_region_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_region(id)

	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlCompositor)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_compositor_interface

	res.create_surface = create_surface
	res.create_region = create_region
	return res
}


WL_INTERFACE_WL_SHM_POOL :: "wl_shm_pool"

WlShmPool :: struct {
	using base:    ^Wl_Base_Interface,
	create_buffer: proc "c" (
		self: ^WlShmPool,
		offset: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
		stride: c.int32_t,
		format: c.uint32_t,
	) -> ^WlBuffer,
	destroy:       proc "c" (self: ^WlShmPool),
	resize:        proc "c" (self: ^WlShmPool, size: c.int32_t),
}

create_wl_shm_pool :: proc "contextless" (proxy: ^wl_proxy) -> ^WlShmPool {
	context = runtime.default_context()
	listener := wl_shm_pool_listener{}

	create_buffer := proc "c" (
		self: ^WlShmPool,
		offset: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
		stride: c.int32_t,
		format: c.uint32_t,
	) -> ^WlBuffer {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_buffer_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
			offset,
			width,
			height,
			stride,
			format,
		)


		return create_wl_buffer(id)

	}
	destroy := proc "c" (self: ^WlShmPool) {
		proxy_marshal_flags(
			self.proxy,
			1,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	resize := proc "c" (self: ^WlShmPool, size: c.int32_t) {
		proxy_marshal_flags(self.proxy, 2, nil, proxy_get_version(self.proxy), 0, size)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlShmPool)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_shm_pool_interface

	res.create_buffer = create_buffer
	res.destroy = destroy
	res.resize = resize
	return res
}


WL_INTERFACE_WL_SHM :: "wl_shm"

WlShm :: struct {
	using base:  ^Wl_Base_Interface,
	create_pool: proc "c" (self: ^WlShm, fd: c.int32_t, size: c.int32_t) -> ^WlShmPool,
}

create_wl_shm :: proc "contextless" (proxy: ^wl_proxy) -> ^WlShm {
	context = runtime.default_context()
	listener := wl_shm_listener {
		format = proc "c" (data: rawptr, wl_shm: ^wl_shm, format: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlShmFormat{format})
		},
	}

	create_pool := proc "c" (self: ^WlShm, fd: c.int32_t, size: c.int32_t) -> ^WlShmPool {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_shm_pool_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
			fd,
			size,
		)


		return create_wl_shm_pool(id)

	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlShm)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_shm_interface

	res.create_pool = create_pool
	return res
}

WlShmFormat :: struct {
	format: c.uint32_t,
}

WL_INTERFACE_WL_BUFFER :: "wl_buffer"

WlBuffer :: struct {
	using base: ^Wl_Base_Interface,
	destroy:    proc "c" (self: ^WlBuffer),
}

create_wl_buffer :: proc "contextless" (proxy: ^wl_proxy) -> ^WlBuffer {
	context = runtime.default_context()
	listener := wl_buffer_listener {
		release = proc "c" (data: rawptr, wl_buffer: ^wl_buffer) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlBufferRelease{})
		},
	}

	destroy := proc "c" (self: ^WlBuffer) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlBuffer)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_buffer_interface

	res.destroy = destroy
	return res
}

WlBufferRelease :: struct {}

WL_INTERFACE_WL_DATA_OFFER :: "wl_data_offer"

WlDataOffer :: struct {
	using base:  ^Wl_Base_Interface,
	accept:      proc "c" (self: ^WlDataOffer, serial: c.uint32_t, mime_type: cstring),
	receive:     proc "c" (self: ^WlDataOffer, mime_type: cstring, fd: c.int32_t),
	destroy:     proc "c" (self: ^WlDataOffer),
	finish:      proc "c" (self: ^WlDataOffer),
	set_actions: proc "c" (
		self: ^WlDataOffer,
		dnd_actions: c.uint32_t,
		preferred_action: c.uint32_t,
	),
}

create_wl_data_offer :: proc "contextless" (proxy: ^wl_proxy) -> ^WlDataOffer {
	context = runtime.default_context()
	listener := wl_data_offer_listener {
		offer = proc "c" (data: rawptr, wl_data_offer: ^wl_data_offer, mime_type: cstring) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataOfferOffer{mime_type})
		},
		source_actions = proc "c" (
			data: rawptr,
			wl_data_offer: ^wl_data_offer,
			source_actions: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataOfferSourceActions{source_actions})
		},
		action = proc "c" (data: rawptr, wl_data_offer: ^wl_data_offer, dnd_action: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataOfferAction{dnd_action})
		},
	}

	accept := proc "c" (self: ^WlDataOffer, serial: c.uint32_t, mime_type: cstring) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			0,
			serial,
			mime_type,
		)


	}
	receive := proc "c" (self: ^WlDataOffer, mime_type: cstring, fd: c.int32_t) {
		proxy_marshal_flags(self.proxy, 1, nil, proxy_get_version(self.proxy), 0, mime_type, fd)


	}
	destroy := proc "c" (self: ^WlDataOffer) {
		proxy_marshal_flags(
			self.proxy,
			2,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	finish := proc "c" (self: ^WlDataOffer) {
		proxy_marshal_flags(self.proxy, 3, nil, proxy_get_version(self.proxy), 0)


	}
	set_actions := proc "c" (
		self: ^WlDataOffer,
		dnd_actions: c.uint32_t,
		preferred_action: c.uint32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			4,
			nil,
			proxy_get_version(self.proxy),
			0,
			dnd_actions,
			preferred_action,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlDataOffer)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_data_offer_interface

	res.accept = accept
	res.receive = receive
	res.destroy = destroy
	res.finish = finish
	res.set_actions = set_actions
	return res
}

WlDataOfferOffer :: struct {
	mime_type: cstring,
}
WlDataOfferSourceActions :: struct {
	source_actions: c.uint32_t,
}
WlDataOfferAction :: struct {
	dnd_action: c.uint32_t,
}

WL_INTERFACE_WL_DATA_SOURCE :: "wl_data_source"

WlDataSource :: struct {
	using base:  ^Wl_Base_Interface,
	offer:       proc "c" (self: ^WlDataSource, mime_type: cstring),
	destroy:     proc "c" (self: ^WlDataSource),
	set_actions: proc "c" (self: ^WlDataSource, dnd_actions: c.uint32_t),
}

create_wl_data_source :: proc "contextless" (proxy: ^wl_proxy) -> ^WlDataSource {
	context = runtime.default_context()
	listener := wl_data_source_listener {
		target = proc "c" (data: rawptr, wl_data_source: ^wl_data_source, mime_type: cstring) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceTarget{mime_type})
		},
		send = proc "c" (
			data: rawptr,
			wl_data_source: ^wl_data_source,
			mime_type: cstring,
			fd: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceSend{mime_type, fd})
		},
		cancelled = proc "c" (data: rawptr, wl_data_source: ^wl_data_source) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceCancelled{})
		},
		dnd_drop_performed = proc "c" (data: rawptr, wl_data_source: ^wl_data_source) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceDndDropPerformed{})
		},
		dnd_finished = proc "c" (data: rawptr, wl_data_source: ^wl_data_source) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceDndFinished{})
		},
		action = proc "c" (data: rawptr, wl_data_source: ^wl_data_source, dnd_action: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataSourceAction{dnd_action})
		},
	}

	offer := proc "c" (self: ^WlDataSource, mime_type: cstring) {
		proxy_marshal_flags(self.proxy, 0, nil, proxy_get_version(self.proxy), 0, mime_type)


	}
	destroy := proc "c" (self: ^WlDataSource) {
		proxy_marshal_flags(
			self.proxy,
			1,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	set_actions := proc "c" (self: ^WlDataSource, dnd_actions: c.uint32_t) {
		proxy_marshal_flags(self.proxy, 2, nil, proxy_get_version(self.proxy), 0, dnd_actions)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlDataSource)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_data_source_interface

	res.offer = offer
	res.destroy = destroy
	res.set_actions = set_actions
	return res
}

WlDataSourceTarget :: struct {
	mime_type: cstring,
}
WlDataSourceSend :: struct {
	mime_type: cstring,
	fd:        c.int32_t,
}
WlDataSourceCancelled :: struct {}
WlDataSourceDndDropPerformed :: struct {}
WlDataSourceDndFinished :: struct {}
WlDataSourceAction :: struct {
	dnd_action: c.uint32_t,
}

WL_INTERFACE_WL_DATA_DEVICE :: "wl_data_device"

WlDataDevice :: struct {
	using base:    ^Wl_Base_Interface,
	start_drag:    proc "c" (
		self: ^WlDataDevice,
		source: ^wl_data_source,
		origin: ^wl_surface,
		icon: ^wl_surface,
		serial: c.uint32_t,
	),
	set_selection: proc "c" (self: ^WlDataDevice, source: ^wl_data_source, serial: c.uint32_t),
	release:       proc "c" (self: ^WlDataDevice),
}

create_wl_data_device :: proc "contextless" (proxy: ^wl_proxy) -> ^WlDataDevice {
	context = runtime.default_context()
	listener := wl_data_device_listener {
		data_offer = proc "c" (data: rawptr, wl_data_device: ^wl_data_device, id: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceDataOffer{id})
		},
		enter = proc "c" (
			data: rawptr,
			wl_data_device: ^wl_data_device,
			serial: c.uint32_t,
			surface: ^wl_surface,
			x: wl_fixed_t,
			y: wl_fixed_t,
			id: ^wl_data_offer,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceEnter{serial, surface, x, y, id})
		},
		leave = proc "c" (data: rawptr, wl_data_device: ^wl_data_device) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceLeave{})
		},
		motion = proc "c" (
			data: rawptr,
			wl_data_device: ^wl_data_device,
			time: c.uint32_t,
			x: wl_fixed_t,
			y: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceMotion{time, x, y})
		},
		drop = proc "c" (data: rawptr, wl_data_device: ^wl_data_device) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceDrop{})
		},
		selection = proc "c" (data: rawptr, wl_data_device: ^wl_data_device, id: ^wl_data_offer) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlDataDeviceSelection{id})
		},
	}

	start_drag := proc "c" (
		self: ^WlDataDevice,
		source: ^wl_data_source,
		origin: ^wl_surface,
		icon: ^wl_surface,
		serial: c.uint32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			0,
			source,
			origin,
			icon,
			serial,
		)


	}
	set_selection := proc "c" (self: ^WlDataDevice, source: ^wl_data_source, serial: c.uint32_t) {
		proxy_marshal_flags(self.proxy, 1, nil, proxy_get_version(self.proxy), 0, source, serial)


	}
	release := proc "c" (self: ^WlDataDevice) {
		proxy_marshal_flags(
			self.proxy,
			2,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlDataDevice)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_data_device_interface

	res.start_drag = start_drag
	res.set_selection = set_selection
	res.release = release
	return res
}

WlDataDeviceDataOffer :: struct {
	id: c.uint32_t,
}
WlDataDeviceEnter :: struct {
	serial:  c.uint32_t,
	surface: ^wl_surface,
	x:       wl_fixed_t,
	y:       wl_fixed_t,
	id:      ^wl_data_offer,
}
WlDataDeviceLeave :: struct {}
WlDataDeviceMotion :: struct {
	time: c.uint32_t,
	x:    wl_fixed_t,
	y:    wl_fixed_t,
}
WlDataDeviceDrop :: struct {}
WlDataDeviceSelection :: struct {
	id: ^wl_data_offer,
}

WL_INTERFACE_WL_DATA_DEVICE_MANAGER :: "wl_data_device_manager"

WlDataDeviceManager :: struct {
	using base:         ^Wl_Base_Interface,
	create_data_source: proc "c" (self: ^WlDataDeviceManager) -> ^WlDataSource,
	get_data_device:    proc "c" (self: ^WlDataDeviceManager, seat: ^wl_seat) -> ^WlDataDevice,
}

create_wl_data_device_manager :: proc "contextless" (proxy: ^wl_proxy) -> ^WlDataDeviceManager {
	context = runtime.default_context()
	listener := wl_data_device_manager_listener{}

	create_data_source := proc "c" (self: ^WlDataDeviceManager) -> ^WlDataSource {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_data_source_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_data_source(id)

	}
	get_data_device := proc "c" (self: ^WlDataDeviceManager, seat: ^wl_seat) -> ^WlDataDevice {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			1,
			&wl_data_device_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
			seat,
		)


		return create_wl_data_device(id)

	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlDataDeviceManager)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_data_device_manager_interface

	res.create_data_source = create_data_source
	res.get_data_device = get_data_device
	return res
}


WL_INTERFACE_WL_SHELL :: "wl_shell"

WlShell :: struct {
	using base:        ^Wl_Base_Interface,
	get_shell_surface: proc "c" (self: ^WlShell, surface: ^wl_surface) -> ^WlShellSurface,
}

create_wl_shell :: proc "contextless" (proxy: ^wl_proxy) -> ^WlShell {
	context = runtime.default_context()
	listener := wl_shell_listener{}

	get_shell_surface := proc "c" (self: ^WlShell, surface: ^wl_surface) -> ^WlShellSurface {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_shell_surface_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
			surface,
		)


		return create_wl_shell_surface(id)

	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlShell)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_shell_interface

	res.get_shell_surface = get_shell_surface
	return res
}


WL_INTERFACE_WL_SHELL_SURFACE :: "wl_shell_surface"

WlShellSurface :: struct {
	using base:     ^Wl_Base_Interface,
	pong:           proc "c" (self: ^WlShellSurface, serial: c.uint32_t),
	move:           proc "c" (self: ^WlShellSurface, seat: ^wl_seat, serial: c.uint32_t),
	resize:         proc "c" (
		self: ^WlShellSurface,
		seat: ^wl_seat,
		serial: c.uint32_t,
		edges: c.uint32_t,
	),
	set_toplevel:   proc "c" (self: ^WlShellSurface),
	set_transient:  proc "c" (
		self: ^WlShellSurface,
		parent: ^wl_surface,
		x: c.int32_t,
		y: c.int32_t,
		flags: c.uint32_t,
	),
	set_fullscreen: proc "c" (
		self: ^WlShellSurface,
		method: c.uint32_t,
		framerate: c.uint32_t,
		output: ^wl_output,
	),
	set_popup:      proc "c" (
		self: ^WlShellSurface,
		seat: ^wl_seat,
		serial: c.uint32_t,
		parent: ^wl_surface,
		x: c.int32_t,
		y: c.int32_t,
		flags: c.uint32_t,
	),
	set_maximized:  proc "c" (self: ^WlShellSurface, output: ^wl_output),
	set_title:      proc "c" (self: ^WlShellSurface, title: cstring),
	set_class:      proc "c" (self: ^WlShellSurface, class_: cstring),
}

create_wl_shell_surface :: proc "contextless" (proxy: ^wl_proxy) -> ^WlShellSurface {
	context = runtime.default_context()
	listener := wl_shell_surface_listener {
		ping = proc "c" (data: rawptr, wl_shell_surface: ^wl_shell_surface, serial: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlShellSurfacePing{serial})
		},
		configure = proc "c" (
			data: rawptr,
			wl_shell_surface: ^wl_shell_surface,
			edges: c.uint32_t,
			width: c.int32_t,
			height: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlShellSurfaceConfigure{edges, width, height})
		},
		popup_done = proc "c" (data: rawptr, wl_shell_surface: ^wl_shell_surface) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlShellSurfacePopupDone{})
		},
	}

	pong := proc "c" (self: ^WlShellSurface, serial: c.uint32_t) {
		proxy_marshal_flags(self.proxy, 0, nil, proxy_get_version(self.proxy), 0, serial)


	}
	move := proc "c" (self: ^WlShellSurface, seat: ^wl_seat, serial: c.uint32_t) {
		proxy_marshal_flags(self.proxy, 1, nil, proxy_get_version(self.proxy), 0, seat, serial)


	}
	resize := proc "c" (
		self: ^WlShellSurface,
		seat: ^wl_seat,
		serial: c.uint32_t,
		edges: c.uint32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			2,
			nil,
			proxy_get_version(self.proxy),
			0,
			seat,
			serial,
			edges,
		)


	}
	set_toplevel := proc "c" (self: ^WlShellSurface) {
		proxy_marshal_flags(self.proxy, 3, nil, proxy_get_version(self.proxy), 0)


	}
	set_transient := proc "c" (
		self: ^WlShellSurface,
		parent: ^wl_surface,
		x: c.int32_t,
		y: c.int32_t,
		flags: c.uint32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			4,
			nil,
			proxy_get_version(self.proxy),
			0,
			parent,
			x,
			y,
			flags,
		)


	}
	set_fullscreen := proc "c" (
		self: ^WlShellSurface,
		method: c.uint32_t,
		framerate: c.uint32_t,
		output: ^wl_output,
	) {
		proxy_marshal_flags(
			self.proxy,
			5,
			nil,
			proxy_get_version(self.proxy),
			0,
			method,
			framerate,
			output,
		)


	}
	set_popup := proc "c" (
		self: ^WlShellSurface,
		seat: ^wl_seat,
		serial: c.uint32_t,
		parent: ^wl_surface,
		x: c.int32_t,
		y: c.int32_t,
		flags: c.uint32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			6,
			nil,
			proxy_get_version(self.proxy),
			0,
			seat,
			serial,
			parent,
			x,
			y,
			flags,
		)


	}
	set_maximized := proc "c" (self: ^WlShellSurface, output: ^wl_output) {
		proxy_marshal_flags(self.proxy, 7, nil, proxy_get_version(self.proxy), 0, output)


	}
	set_title := proc "c" (self: ^WlShellSurface, title: cstring) {
		proxy_marshal_flags(self.proxy, 8, nil, proxy_get_version(self.proxy), 0, title)


	}
	set_class := proc "c" (self: ^WlShellSurface, class_: cstring) {
		proxy_marshal_flags(self.proxy, 9, nil, proxy_get_version(self.proxy), 0, class_)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlShellSurface)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_shell_surface_interface

	res.pong = pong
	res.move = move
	res.resize = resize
	res.set_toplevel = set_toplevel
	res.set_transient = set_transient
	res.set_fullscreen = set_fullscreen
	res.set_popup = set_popup
	res.set_maximized = set_maximized
	res.set_title = set_title
	res.set_class = set_class
	return res
}

WlShellSurfacePing :: struct {
	serial: c.uint32_t,
}
WlShellSurfaceConfigure :: struct {
	edges:  c.uint32_t,
	width:  c.int32_t,
	height: c.int32_t,
}
WlShellSurfacePopupDone :: struct {}

WL_INTERFACE_WL_SURFACE :: "wl_surface"

WlSurface :: struct {
	using base:           ^Wl_Base_Interface,
	destroy:              proc "c" (self: ^WlSurface),
	attach:               proc "c" (
		self: ^WlSurface,
		buffer: ^wl_buffer,
		x: c.int32_t,
		y: c.int32_t,
	),
	damage:               proc "c" (
		self: ^WlSurface,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	),
	frame:                proc "c" (self: ^WlSurface) -> ^WlCallback,
	set_opaque_region:    proc "c" (self: ^WlSurface, region: ^wl_region),
	set_input_region:     proc "c" (self: ^WlSurface, region: ^wl_region),
	commit:               proc "c" (self: ^WlSurface),
	set_buffer_transform: proc "c" (self: ^WlSurface, transform: c.uint32_t),
	set_buffer_scale:     proc "c" (self: ^WlSurface, scale: c.int32_t),
	damage_buffer:        proc "c" (
		self: ^WlSurface,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	),
	offset:               proc "c" (self: ^WlSurface, x: c.int32_t, y: c.int32_t),
}

create_wl_surface :: proc "contextless" (proxy: ^wl_proxy) -> ^WlSurface {
	context = runtime.default_context()
	listener := wl_surface_listener {
		enter = proc "c" (data: rawptr, wl_surface: ^wl_surface, output: ^wl_output) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSurfaceEnter{output})
		},
		leave = proc "c" (data: rawptr, wl_surface: ^wl_surface, output: ^wl_output) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSurfaceLeave{output})
		},
		preferred_buffer_scale = proc "c" (
			data: rawptr,
			wl_surface: ^wl_surface,
			factor: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSurfacePreferredBufferScale{factor})
		},
		preferred_buffer_transform = proc "c" (
			data: rawptr,
			wl_surface: ^wl_surface,
			transform: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSurfacePreferredBufferTransform{transform})
		},
	}

	destroy := proc "c" (self: ^WlSurface) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	attach := proc "c" (self: ^WlSurface, buffer: ^wl_buffer, x: c.int32_t, y: c.int32_t) {
		proxy_marshal_flags(self.proxy, 1, nil, proxy_get_version(self.proxy), 0, buffer, x, y)


	}
	damage := proc "c" (
		self: ^WlSurface,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			2,
			nil,
			proxy_get_version(self.proxy),
			0,
			x,
			y,
			width,
			height,
		)


	}
	frame := proc "c" (self: ^WlSurface) -> ^WlCallback {
		callback: ^wl_proxy
		callback = proxy_marshal_flags(
			self.proxy,
			3,
			&wl_callback_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_callback(callback)

	}
	set_opaque_region := proc "c" (self: ^WlSurface, region: ^wl_region) {
		proxy_marshal_flags(self.proxy, 4, nil, proxy_get_version(self.proxy), 0, region)


	}
	set_input_region := proc "c" (self: ^WlSurface, region: ^wl_region) {
		proxy_marshal_flags(self.proxy, 5, nil, proxy_get_version(self.proxy), 0, region)


	}
	commit := proc "c" (self: ^WlSurface) {
		proxy_marshal_flags(self.proxy, 6, nil, proxy_get_version(self.proxy), 0)


	}
	set_buffer_transform := proc "c" (self: ^WlSurface, transform: c.uint32_t) {
		proxy_marshal_flags(self.proxy, 7, nil, proxy_get_version(self.proxy), 0, transform)


	}
	set_buffer_scale := proc "c" (self: ^WlSurface, scale: c.int32_t) {
		proxy_marshal_flags(self.proxy, 8, nil, proxy_get_version(self.proxy), 0, scale)


	}
	damage_buffer := proc "c" (
		self: ^WlSurface,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			9,
			nil,
			proxy_get_version(self.proxy),
			0,
			x,
			y,
			width,
			height,
		)


	}
	offset := proc "c" (self: ^WlSurface, x: c.int32_t, y: c.int32_t) {
		proxy_marshal_flags(self.proxy, 10, nil, proxy_get_version(self.proxy), 0, x, y)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlSurface)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_surface_interface

	res.destroy = destroy
	res.attach = attach
	res.damage = damage
	res.frame = frame
	res.set_opaque_region = set_opaque_region
	res.set_input_region = set_input_region
	res.commit = commit
	res.set_buffer_transform = set_buffer_transform
	res.set_buffer_scale = set_buffer_scale
	res.damage_buffer = damage_buffer
	res.offset = offset
	return res
}

WlSurfaceEnter :: struct {
	output: ^wl_output,
}
WlSurfaceLeave :: struct {
	output: ^wl_output,
}
WlSurfacePreferredBufferScale :: struct {
	factor: c.int32_t,
}
WlSurfacePreferredBufferTransform :: struct {
	transform: c.uint32_t,
}

WL_INTERFACE_WL_SEAT :: "wl_seat"

WlSeat :: struct {
	using base:   ^Wl_Base_Interface,
	get_pointer:  proc "c" (self: ^WlSeat) -> ^WlPointer,
	get_keyboard: proc "c" (self: ^WlSeat) -> ^WlKeyboard,
	get_touch:    proc "c" (self: ^WlSeat) -> ^WlTouch,
	release:      proc "c" (self: ^WlSeat),
}

create_wl_seat :: proc "contextless" (proxy: ^wl_proxy) -> ^WlSeat {
	context = runtime.default_context()
	listener := wl_seat_listener {
		capabilities = proc "c" (data: rawptr, wl_seat: ^wl_seat, capabilities: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSeatCapabilities{capabilities})
		},
		name = proc "c" (data: rawptr, wl_seat: ^wl_seat, name: cstring) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlSeatName{name})
		},
	}

	get_pointer := proc "c" (self: ^WlSeat) -> ^WlPointer {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			0,
			&wl_pointer_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_pointer(id)

	}
	get_keyboard := proc "c" (self: ^WlSeat) -> ^WlKeyboard {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			1,
			&wl_keyboard_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_keyboard(id)

	}
	get_touch := proc "c" (self: ^WlSeat) -> ^WlTouch {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			2,
			&wl_touch_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
		)


		return create_wl_touch(id)

	}
	release := proc "c" (self: ^WlSeat) {
		proxy_marshal_flags(
			self.proxy,
			3,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlSeat)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_seat_interface

	res.get_pointer = get_pointer
	res.get_keyboard = get_keyboard
	res.get_touch = get_touch
	res.release = release
	return res
}

WlSeatCapabilities :: struct {
	capabilities: c.uint32_t,
}
WlSeatName :: struct {
	name: cstring,
}

WL_INTERFACE_WL_POINTER :: "wl_pointer"

WlPointer :: struct {
	using base: ^Wl_Base_Interface,
	set_cursor: proc "c" (
		self: ^WlPointer,
		serial: c.uint32_t,
		surface: ^wl_surface,
		hotspot_x: c.int32_t,
		hotspot_y: c.int32_t,
	),
	release:    proc "c" (self: ^WlPointer),
}

create_wl_pointer :: proc "contextless" (proxy: ^wl_proxy) -> ^WlPointer {
	context = runtime.default_context()
	listener := wl_pointer_listener {
		enter = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			serial: c.uint32_t,
			surface: ^wl_surface,
			surface_x: wl_fixed_t,
			surface_y: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerEnter{serial, surface, surface_x, surface_y})
		},
		leave = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			serial: c.uint32_t,
			surface: ^wl_surface,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerLeave{serial, surface})
		},
		motion = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			time: c.uint32_t,
			surface_x: wl_fixed_t,
			surface_y: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerMotion{time, surface_x, surface_y})
		},
		button = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			serial: c.uint32_t,
			time: c.uint32_t,
			button: c.uint32_t,
			state: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerButton{serial, time, button, state})
		},
		axis = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			time: c.uint32_t,
			axis: c.uint32_t,
			value: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxis{time, axis, value})
		},
		frame = proc "c" (data: rawptr, wl_pointer: ^wl_pointer) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerFrame{})
		},
		axis_source = proc "c" (data: rawptr, wl_pointer: ^wl_pointer, axis_source: c.uint32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxisSource{axis_source})
		},
		axis_stop = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			time: c.uint32_t,
			axis: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxisStop{time, axis})
		},
		axis_discrete = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			axis: c.uint32_t,
			discrete: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxisDiscrete{axis, discrete})
		},
		axis_value120 = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			axis: c.uint32_t,
			value120: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxisValue120{axis, value120})
		},
		axis_relative_direction = proc "c" (
			data: rawptr,
			wl_pointer: ^wl_pointer,
			axis: c.uint32_t,
			direction: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlPointerAxisRelativeDirection{axis, direction})
		},
	}

	set_cursor := proc "c" (
		self: ^WlPointer,
		serial: c.uint32_t,
		surface: ^wl_surface,
		hotspot_x: c.int32_t,
		hotspot_y: c.int32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			0,
			serial,
			surface,
			hotspot_x,
			hotspot_y,
		)


	}
	release := proc "c" (self: ^WlPointer) {
		proxy_marshal_flags(
			self.proxy,
			1,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlPointer)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_pointer_interface

	res.set_cursor = set_cursor
	res.release = release
	return res
}

WlPointerEnter :: struct {
	serial:    c.uint32_t,
	surface:   ^wl_surface,
	surface_x: wl_fixed_t,
	surface_y: wl_fixed_t,
}
WlPointerLeave :: struct {
	serial:  c.uint32_t,
	surface: ^wl_surface,
}
WlPointerMotion :: struct {
	time:      c.uint32_t,
	surface_x: wl_fixed_t,
	surface_y: wl_fixed_t,
}
WlPointerButton :: struct {
	serial: c.uint32_t,
	time:   c.uint32_t,
	button: c.uint32_t,
	state:  c.uint32_t,
}
WlPointerAxis :: struct {
	time:  c.uint32_t,
	axis:  c.uint32_t,
	value: wl_fixed_t,
}
WlPointerFrame :: struct {}
WlPointerAxisSource :: struct {
	axis_source: c.uint32_t,
}
WlPointerAxisStop :: struct {
	time: c.uint32_t,
	axis: c.uint32_t,
}
WlPointerAxisDiscrete :: struct {
	axis:     c.uint32_t,
	discrete: c.int32_t,
}
WlPointerAxisValue120 :: struct {
	axis:     c.uint32_t,
	value120: c.int32_t,
}
WlPointerAxisRelativeDirection :: struct {
	axis:      c.uint32_t,
	direction: c.uint32_t,
}

WL_INTERFACE_WL_KEYBOARD :: "wl_keyboard"

WlKeyboard :: struct {
	using base: ^Wl_Base_Interface,
	release:    proc "c" (self: ^WlKeyboard),
}

create_wl_keyboard :: proc "contextless" (proxy: ^wl_proxy) -> ^WlKeyboard {
	context = runtime.default_context()
	listener := wl_keyboard_listener {
		keymap = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			format: c.uint32_t,
			fd: c.int32_t,
			size: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlKeyboardKeymap{format, fd, size})
		},
		enter = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			serial: c.uint32_t,
			surface: ^wl_surface,
			keys: ^wl_array,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlKeyboardEnter{serial, surface, keys})
		},
		leave = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			serial: c.uint32_t,
			surface: ^wl_surface,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlKeyboardLeave{serial, surface})
		},
		key = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			serial: c.uint32_t,
			time: c.uint32_t,
			key: c.uint32_t,
			state: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlKeyboardKey{serial, time, key, state})
		},
		modifiers = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			serial: c.uint32_t,
			mods_depressed: c.uint32_t,
			mods_latched: c.uint32_t,
			mods_locked: c.uint32_t,
			group: c.uint32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(
				&wh.queue,
				WlKeyboardModifiers{serial, mods_depressed, mods_latched, mods_locked, group},
			)
		},
		repeat_info = proc "c" (
			data: rawptr,
			wl_keyboard: ^wl_keyboard,
			rate: c.int32_t,
			delay: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlKeyboardRepeatInfo{rate, delay})
		},
	}

	release := proc "c" (self: ^WlKeyboard) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlKeyboard)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_keyboard_interface

	res.release = release
	return res
}

WlKeyboardKeymap :: struct {
	format: c.uint32_t,
	fd:     c.int32_t,
	size:   c.uint32_t,
}
WlKeyboardEnter :: struct {
	serial:  c.uint32_t,
	surface: ^wl_surface,
	keys:    ^wl_array,
}
WlKeyboardLeave :: struct {
	serial:  c.uint32_t,
	surface: ^wl_surface,
}
WlKeyboardKey :: struct {
	serial: c.uint32_t,
	time:   c.uint32_t,
	key:    c.uint32_t,
	state:  c.uint32_t,
}
WlKeyboardModifiers :: struct {
	serial:         c.uint32_t,
	mods_depressed: c.uint32_t,
	mods_latched:   c.uint32_t,
	mods_locked:    c.uint32_t,
	group:          c.uint32_t,
}
WlKeyboardRepeatInfo :: struct {
	rate:  c.int32_t,
	delay: c.int32_t,
}

WL_INTERFACE_WL_TOUCH :: "wl_touch"

WlTouch :: struct {
	using base: ^Wl_Base_Interface,
	release:    proc "c" (self: ^WlTouch),
}

create_wl_touch :: proc "contextless" (proxy: ^wl_proxy) -> ^WlTouch {
	context = runtime.default_context()
	listener := wl_touch_listener {
		down = proc "c" (
			data: rawptr,
			wl_touch: ^wl_touch,
			serial: c.uint32_t,
			time: c.uint32_t,
			surface: ^wl_surface,
			id: c.int32_t,
			x: wl_fixed_t,
			y: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchDown{serial, time, surface, id, x, y})
		},
		up = proc "c" (
			data: rawptr,
			wl_touch: ^wl_touch,
			serial: c.uint32_t,
			time: c.uint32_t,
			id: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchUp{serial, time, id})
		},
		motion = proc "c" (
			data: rawptr,
			wl_touch: ^wl_touch,
			time: c.uint32_t,
			id: c.int32_t,
			x: wl_fixed_t,
			y: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchMotion{time, id, x, y})
		},
		frame = proc "c" (data: rawptr, wl_touch: ^wl_touch) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchFrame{})
		},
		cancel = proc "c" (data: rawptr, wl_touch: ^wl_touch) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchCancel{})
		},
		shape = proc "c" (
			data: rawptr,
			wl_touch: ^wl_touch,
			id: c.int32_t,
			major: wl_fixed_t,
			minor: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchShape{id, major, minor})
		},
		orientation = proc "c" (
			data: rawptr,
			wl_touch: ^wl_touch,
			id: c.int32_t,
			orientation: wl_fixed_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlTouchOrientation{id, orientation})
		},
	}

	release := proc "c" (self: ^WlTouch) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlTouch)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_touch_interface

	res.release = release
	return res
}

WlTouchDown :: struct {
	serial:  c.uint32_t,
	time:    c.uint32_t,
	surface: ^wl_surface,
	id:      c.int32_t,
	x:       wl_fixed_t,
	y:       wl_fixed_t,
}
WlTouchUp :: struct {
	serial: c.uint32_t,
	time:   c.uint32_t,
	id:     c.int32_t,
}
WlTouchMotion :: struct {
	time: c.uint32_t,
	id:   c.int32_t,
	x:    wl_fixed_t,
	y:    wl_fixed_t,
}
WlTouchFrame :: struct {}
WlTouchCancel :: struct {}
WlTouchShape :: struct {
	id:    c.int32_t,
	major: wl_fixed_t,
	minor: wl_fixed_t,
}
WlTouchOrientation :: struct {
	id:          c.int32_t,
	orientation: wl_fixed_t,
}

WL_INTERFACE_WL_OUTPUT :: "wl_output"

WlOutput :: struct {
	using base: ^Wl_Base_Interface,
	release:    proc "c" (self: ^WlOutput),
}

create_wl_output :: proc "contextless" (proxy: ^wl_proxy) -> ^WlOutput {
	context = runtime.default_context()
	listener := wl_output_listener {
		geometry = proc "c" (
			data: rawptr,
			wl_output: ^wl_output,
			x: c.int32_t,
			y: c.int32_t,
			physical_width: c.int32_t,
			physical_height: c.int32_t,
			subpixel: c.int32_t,
			make: cstring,
			model: cstring,
			transform: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(
				&wh.queue,
				WlOutputGeometry {
					x,
					y,
					physical_width,
					physical_height,
					subpixel,
					make,
					model,
					transform,
				},
			)
		},
		mode = proc "c" (
			data: rawptr,
			wl_output: ^wl_output,
			flags: c.uint32_t,
			width: c.int32_t,
			height: c.int32_t,
			refresh: c.int32_t,
		) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlOutputMode{flags, width, height, refresh})
		},
		done = proc "c" (data: rawptr, wl_output: ^wl_output) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlOutputDone{})
		},
		scale = proc "c" (data: rawptr, wl_output: ^wl_output, factor: c.int32_t) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlOutputScale{factor})
		},
		name = proc "c" (data: rawptr, wl_output: ^wl_output, name: cstring) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlOutputName{name})
		},
		description = proc "c" (data: rawptr, wl_output: ^wl_output, description: cstring) {
			// Send message to the queue
			context = runtime.default_context()
			queue.enqueue(&wh.queue, WlOutputDescription{description})
		},
	}

	release := proc "c" (self: ^WlOutput) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlOutput)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_output_interface

	res.release = release
	return res
}

WlOutputGeometry :: struct {
	x:               c.int32_t,
	y:               c.int32_t,
	physical_width:  c.int32_t,
	physical_height: c.int32_t,
	subpixel:        c.int32_t,
	make:            cstring,
	model:           cstring,
	transform:       c.int32_t,
}
WlOutputMode :: struct {
	flags:   c.uint32_t,
	width:   c.int32_t,
	height:  c.int32_t,
	refresh: c.int32_t,
}
WlOutputDone :: struct {}
WlOutputScale :: struct {
	factor: c.int32_t,
}
WlOutputName :: struct {
	name: cstring,
}
WlOutputDescription :: struct {
	description: cstring,
}

WL_INTERFACE_WL_REGION :: "wl_region"

WlRegion :: struct {
	using base: ^Wl_Base_Interface,
	destroy:    proc "c" (self: ^WlRegion),
	add:        proc "c" (
		self: ^WlRegion,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	),
	subtract:   proc "c" (
		self: ^WlRegion,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	),
}

create_wl_region :: proc "contextless" (proxy: ^wl_proxy) -> ^WlRegion {
	context = runtime.default_context()
	listener := wl_region_listener{}

	destroy := proc "c" (self: ^WlRegion) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	add := proc "c" (
		self: ^WlRegion,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			1,
			nil,
			proxy_get_version(self.proxy),
			0,
			x,
			y,
			width,
			height,
		)


	}
	subtract := proc "c" (
		self: ^WlRegion,
		x: c.int32_t,
		y: c.int32_t,
		width: c.int32_t,
		height: c.int32_t,
	) {
		proxy_marshal_flags(
			self.proxy,
			2,
			nil,
			proxy_get_version(self.proxy),
			0,
			x,
			y,
			width,
			height,
		)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlRegion)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_region_interface

	res.destroy = destroy
	res.add = add
	res.subtract = subtract
	return res
}


WL_INTERFACE_WL_SUBCOMPOSITOR :: "wl_subcompositor"

WlSubcompositor :: struct {
	using base:     ^Wl_Base_Interface,
	destroy:        proc "c" (self: ^WlSubcompositor),
	get_subsurface: proc "c" (
		self: ^WlSubcompositor,
		surface: ^wl_surface,
		parent: ^wl_surface,
	) -> ^WlSubsurface,
}

create_wl_subcompositor :: proc "contextless" (proxy: ^wl_proxy) -> ^WlSubcompositor {
	context = runtime.default_context()
	listener := wl_subcompositor_listener{}

	destroy := proc "c" (self: ^WlSubcompositor) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	get_subsurface := proc "c" (
		self: ^WlSubcompositor,
		surface: ^wl_surface,
		parent: ^wl_surface,
	) -> ^WlSubsurface {
		id: ^wl_proxy
		id = proxy_marshal_flags(
			self.proxy,
			1,
			&wl_subsurface_interface,
			proxy_get_version(self.proxy),
			0,
			nil,
			surface,
			parent,
		)


		return create_wl_subsurface(id)

	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlSubcompositor)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_subcompositor_interface

	res.destroy = destroy
	res.get_subsurface = get_subsurface
	return res
}


WL_INTERFACE_WL_SUBSURFACE :: "wl_subsurface"

WlSubsurface :: struct {
	using base:   ^Wl_Base_Interface,
	destroy:      proc "c" (self: ^WlSubsurface),
	set_position: proc "c" (self: ^WlSubsurface, x: c.int32_t, y: c.int32_t),
	place_above:  proc "c" (self: ^WlSubsurface, sibling: ^wl_surface),
	place_below:  proc "c" (self: ^WlSubsurface, sibling: ^wl_surface),
	set_sync:     proc "c" (self: ^WlSubsurface),
	set_desync:   proc "c" (self: ^WlSubsurface),
}

create_wl_subsurface :: proc "contextless" (proxy: ^wl_proxy) -> ^WlSubsurface {
	context = runtime.default_context()
	listener := wl_subsurface_listener{}

	destroy := proc "c" (self: ^WlSubsurface) {
		proxy_marshal_flags(
			self.proxy,
			0,
			nil,
			proxy_get_version(self.proxy),
			WL_MARSHAL_FLAG_DESTROY,
		)


	}
	set_position := proc "c" (self: ^WlSubsurface, x: c.int32_t, y: c.int32_t) {
		proxy_marshal_flags(self.proxy, 1, nil, proxy_get_version(self.proxy), 0, x, y)


	}
	place_above := proc "c" (self: ^WlSubsurface, sibling: ^wl_surface) {
		proxy_marshal_flags(self.proxy, 2, nil, proxy_get_version(self.proxy), 0, sibling)


	}
	place_below := proc "c" (self: ^WlSubsurface, sibling: ^wl_surface) {
		proxy_marshal_flags(self.proxy, 3, nil, proxy_get_version(self.proxy), 0, sibling)


	}
	set_sync := proc "c" (self: ^WlSubsurface) {
		proxy_marshal_flags(self.proxy, 4, nil, proxy_get_version(self.proxy), 0)


	}
	set_desync := proc "c" (self: ^WlSubsurface) {
		proxy_marshal_flags(self.proxy, 5, nil, proxy_get_version(self.proxy), 0)


	}

	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)
	roundtrip()
	res := new(WlSubsurface)
	res.base = new(Wl_Base_Interface)
	res.proxy = proxy
	res.interface = &wl_subsurface_interface

	res.destroy = destroy
	res.set_position = set_position
	res.place_above = place_above
	res.place_below = place_below
	res.set_sync = set_sync
	res.set_desync = set_desync
	return res
}


WlEvent :: union {
	WlDisplayError,
	WlDisplayDeleteId,
	WlRegistryGlobal,
	WlRegistryGlobalRemove,
	WlCallbackDone,
	WlShmFormat,
	WlBufferRelease,
	WlDataOfferOffer,
	WlDataOfferSourceActions,
	WlDataOfferAction,
	WlDataSourceTarget,
	WlDataSourceSend,
	WlDataSourceCancelled,
	WlDataSourceDndDropPerformed,
	WlDataSourceDndFinished,
	WlDataSourceAction,
	WlDataDeviceDataOffer,
	WlDataDeviceEnter,
	WlDataDeviceLeave,
	WlDataDeviceMotion,
	WlDataDeviceDrop,
	WlDataDeviceSelection,
	WlShellSurfacePing,
	WlShellSurfaceConfigure,
	WlShellSurfacePopupDone,
	WlSurfaceEnter,
	WlSurfaceLeave,
	WlSurfacePreferredBufferScale,
	WlSurfacePreferredBufferTransform,
	WlSeatCapabilities,
	WlSeatName,
	WlPointerEnter,
	WlPointerLeave,
	WlPointerMotion,
	WlPointerButton,
	WlPointerAxis,
	WlPointerFrame,
	WlPointerAxisSource,
	WlPointerAxisStop,
	WlPointerAxisDiscrete,
	WlPointerAxisValue120,
	WlPointerAxisRelativeDirection,
	WlKeyboardKeymap,
	WlKeyboardEnter,
	WlKeyboardLeave,
	WlKeyboardKey,
	WlKeyboardModifiers,
	WlKeyboardRepeatInfo,
	WlTouchDown,
	WlTouchUp,
	WlTouchMotion,
	WlTouchFrame,
	WlTouchCancel,
	WlTouchShape,
	WlTouchOrientation,
	WlOutputGeometry,
	WlOutputMode,
	WlOutputDone,
	WlOutputScale,
	WlOutputName,
	WlOutputDescription,
}
