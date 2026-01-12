package wayland

import "core:c"

WL_INTERFACE_WL_DISPLAY :: "wl_display"

WlDisplay :: struct {
    using base: ^Wl_Base_Interface,


    sync : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_callback,

    get_registry : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_registry,
}

create_wl_display :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlDisplay {
    context = runtime.default_context()
    listener = wl_display_listener {
        error = proc "c" (
            data: rawptr,
            wl_display: ^wl_display,
            object_id: rawptr,
            code: c.uint32_t,
            message: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDisplayError {})
        },
        delete_id = proc "c" (
            data: rawptr,
            wl_display: ^wl_display,
            id: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDisplayDeleteId {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlDisplay)
    res.proxy = proxy
    res.interface = &wl_display_interface

    res.sync = _sync
    res.get_registry = _get_registry
}   


WL_INTERFACE_WL_REGISTRY :: "wl_registry"

WlRegistry :: struct {
    using base: ^Wl_Base_Interface,


    bind : proc "c" (
        proxy: ^wl_proxy,
        name : c.uint32_t,interface: ^wl_interface, version: c.uint32_t
    ) ->rawptr,
}

create_wl_registry :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlRegistry {
    context = runtime.default_context()
    listener = wl_registry_listener {
        global = proc "c" (
            data: rawptr,
            wl_registry: ^wl_registry,
            name: c.uint32_t,
            interface: cstring,
            version: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlRegistryGlobal {})
        },
        global_remove = proc "c" (
            data: rawptr,
            wl_registry: ^wl_registry,
            name: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlRegistryGlobalRemove {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlRegistry)
    res.proxy = proxy
    res.interface = &wl_registry_interface

    res.bind = _bind
}   


WL_INTERFACE_WL_CALLBACK :: "wl_callback"

WlCallback :: struct {
    using base: ^Wl_Base_Interface,

}

create_wl_callback :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlCallback {
    context = runtime.default_context()
    listener = wl_callback_listener {
        done = proc "c" (
            data: rawptr,
            wl_callback: ^wl_callback,
            callback_data: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlCallbackDone {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlCallback)
    res.proxy = proxy
    res.interface = &wl_callback_interface

}   


WL_INTERFACE_WL_COMPOSITOR :: "wl_compositor"

WlCompositor :: struct {
    using base: ^Wl_Base_Interface,


    create_surface : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_surface,

    create_region : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_region,
}

create_wl_compositor :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlCompositor {
    context = runtime.default_context()
    listener = wl_compositor_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlCompositor)
    res.proxy = proxy
    res.interface = &wl_compositor_interface

    res.create_surface = _create_surface
    res.create_region = _create_region
}   


WL_INTERFACE_WL_SHM_POOL :: "wl_shm_pool"

WlShmPool :: struct {
    using base: ^Wl_Base_Interface,


    create_buffer : proc "c" (
        proxy: ^wl_proxy,
        offset : c.int32_t,width : c.int32_t,height : c.int32_t,stride : c.int32_t,format : c.uint32_t
    ) ->^wl_buffer,

    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    resize : proc "c" (
        proxy: ^wl_proxy,
        size : c.int32_t
    ) ,
}

create_wl_shm_pool :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlShmPool {
    context = runtime.default_context()
    listener = wl_shm_pool_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlShmPool)
    res.proxy = proxy
    res.interface = &wl_shm_pool_interface

    res.create_buffer = _create_buffer
    res.destroy = _destroy
    res.resize = _resize
}   


WL_INTERFACE_WL_SHM :: "wl_shm"

WlShm :: struct {
    using base: ^Wl_Base_Interface,


    create_pool : proc "c" (
        proxy: ^wl_proxy,
        fd : c.int32_t,size : c.int32_t
    ) ->^wl_shm_pool,
}

create_wl_shm :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlShm {
    context = runtime.default_context()
    listener = wl_shm_listener {
        format = proc "c" (
            data: rawptr,
            wl_shm: ^wl_shm,
            format: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlShmFormat {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlShm)
    res.proxy = proxy
    res.interface = &wl_shm_interface

    res.create_pool = _create_pool
}   


WL_INTERFACE_WL_BUFFER :: "wl_buffer"

WlBuffer :: struct {
    using base: ^Wl_Base_Interface,


    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_buffer :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlBuffer {
    context = runtime.default_context()
    listener = wl_buffer_listener {
        release = proc "c" (
            data: rawptr,
            wl_buffer: ^wl_buffer,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlBufferRelease {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlBuffer)
    res.proxy = proxy
    res.interface = &wl_buffer_interface

    res.destroy = _destroy
}   


WL_INTERFACE_WL_DATA_OFFER :: "wl_data_offer"

WlDataOffer :: struct {
    using base: ^Wl_Base_Interface,


    accept : proc "c" (
        proxy: ^wl_proxy,
        serial : c.uint32_t,mime_type : cstring
    ) ,

    receive : proc "c" (
        proxy: ^wl_proxy,
        mime_type : cstring,fd : c.int32_t
    ) ,

    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    finish : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_actions : proc "c" (
        proxy: ^wl_proxy,
        dnd_actions : c.uint32_t,preferred_action : c.uint32_t
    ) ,
}

create_wl_data_offer :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlDataOffer {
    context = runtime.default_context()
    listener = wl_data_offer_listener {
        offer = proc "c" (
            data: rawptr,
            wl_data_offer: ^wl_data_offer,
            mime_type: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataOfferOffer {})
        },
        source_actions = proc "c" (
            data: rawptr,
            wl_data_offer: ^wl_data_offer,
            source_actions: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataOfferSourceActions {})
        },
        action = proc "c" (
            data: rawptr,
            wl_data_offer: ^wl_data_offer,
            dnd_action: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataOfferAction {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlDataOffer)
    res.proxy = proxy
    res.interface = &wl_data_offer_interface

    res.accept = _accept
    res.receive = _receive
    res.destroy = _destroy
    res.finish = _finish
    res.set_actions = _set_actions
}   


WL_INTERFACE_WL_DATA_SOURCE :: "wl_data_source"

WlDataSource :: struct {
    using base: ^Wl_Base_Interface,


    offer : proc "c" (
        proxy: ^wl_proxy,
        mime_type : cstring
    ) ,

    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_actions : proc "c" (
        proxy: ^wl_proxy,
        dnd_actions : c.uint32_t
    ) ,
}

create_wl_data_source :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlDataSource {
    context = runtime.default_context()
    listener = wl_data_source_listener {
        target = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
            mime_type: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceTarget {})
        },
        send = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
            mime_type: cstring,
            fd: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceSend {})
        },
        cancelled = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceCancelled {})
        },
        dnd_drop_performed = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceDndDropPerformed {})
        },
        dnd_finished = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceDndFinished {})
        },
        action = proc "c" (
            data: rawptr,
            wl_data_source: ^wl_data_source,
            dnd_action: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataSourceAction {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlDataSource)
    res.proxy = proxy
    res.interface = &wl_data_source_interface

    res.offer = _offer
    res.destroy = _destroy
    res.set_actions = _set_actions
}   


WL_INTERFACE_WL_DATA_DEVICE :: "wl_data_device"

WlDataDevice :: struct {
    using base: ^Wl_Base_Interface,


    start_drag : proc "c" (
        proxy: ^wl_proxy,
        source : ^wl_data_source,origin : ^wl_surface,icon : ^wl_surface,serial : c.uint32_t
    ) ,

    set_selection : proc "c" (
        proxy: ^wl_proxy,
        source : ^wl_data_source,serial : c.uint32_t
    ) ,

    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_data_device :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlDataDevice {
    context = runtime.default_context()
    listener = wl_data_device_listener {
        data_offer = proc "c" (
            data: rawptr,
            wl_data_device: ^wl_data_device,
            id: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataDeviceDataOffer {})
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
            queue.enqueue(&wh.queue, WlDataDeviceEnter {})
        },
        leave = proc "c" (
            data: rawptr,
            wl_data_device: ^wl_data_device,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataDeviceLeave {})
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
            queue.enqueue(&wh.queue, WlDataDeviceMotion {})
        },
        drop = proc "c" (
            data: rawptr,
            wl_data_device: ^wl_data_device,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataDeviceDrop {})
        },
        selection = proc "c" (
            data: rawptr,
            wl_data_device: ^wl_data_device,
            id: ^wl_data_offer,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlDataDeviceSelection {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlDataDevice)
    res.proxy = proxy
    res.interface = &wl_data_device_interface

    res.start_drag = _start_drag
    res.set_selection = _set_selection
    res.release = _release
}   


WL_INTERFACE_WL_DATA_DEVICE_MANAGER :: "wl_data_device_manager"

WlDataDeviceManager :: struct {
    using base: ^Wl_Base_Interface,


    create_data_source : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_data_source,

    get_data_device : proc "c" (
        proxy: ^wl_proxy,
        seat : ^wl_seat
    ) ->^wl_data_device,
}

create_wl_data_device_manager :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlDataDeviceManager {
    context = runtime.default_context()
    listener = wl_data_device_manager_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlDataDeviceManager)
    res.proxy = proxy
    res.interface = &wl_data_device_manager_interface

    res.create_data_source = _create_data_source
    res.get_data_device = _get_data_device
}   


WL_INTERFACE_WL_SHELL :: "wl_shell"

WlShell :: struct {
    using base: ^Wl_Base_Interface,


    get_shell_surface : proc "c" (
        proxy: ^wl_proxy,
        surface : ^wl_surface
    ) ->^wl_shell_surface,
}

create_wl_shell :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlShell {
    context = runtime.default_context()
    listener = wl_shell_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlShell)
    res.proxy = proxy
    res.interface = &wl_shell_interface

    res.get_shell_surface = _get_shell_surface
}   


WL_INTERFACE_WL_SHELL_SURFACE :: "wl_shell_surface"

WlShellSurface :: struct {
    using base: ^Wl_Base_Interface,


    pong : proc "c" (
        proxy: ^wl_proxy,
        serial : c.uint32_t
    ) ,

    move : proc "c" (
        proxy: ^wl_proxy,
        seat : ^wl_seat,serial : c.uint32_t
    ) ,

    resize : proc "c" (
        proxy: ^wl_proxy,
        seat : ^wl_seat,serial : c.uint32_t,edges : c.uint32_t
    ) ,

    set_toplevel : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_transient : proc "c" (
        proxy: ^wl_proxy,
        parent : ^wl_surface,x : c.int32_t,y : c.int32_t,flags : c.uint32_t
    ) ,

    set_fullscreen : proc "c" (
        proxy: ^wl_proxy,
        method : c.uint32_t,framerate : c.uint32_t,output : ^wl_output
    ) ,

    set_popup : proc "c" (
        proxy: ^wl_proxy,
        seat : ^wl_seat,serial : c.uint32_t,parent : ^wl_surface,x : c.int32_t,y : c.int32_t,flags : c.uint32_t
    ) ,

    set_maximized : proc "c" (
        proxy: ^wl_proxy,
        output : ^wl_output
    ) ,

    set_title : proc "c" (
        proxy: ^wl_proxy,
        title : cstring
    ) ,

    set_class : proc "c" (
        proxy: ^wl_proxy,
        class_ : cstring
    ) ,
}

create_wl_shell_surface :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlShellSurface {
    context = runtime.default_context()
    listener = wl_shell_surface_listener {
        ping = proc "c" (
            data: rawptr,
            wl_shell_surface: ^wl_shell_surface,
            serial: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlShellSurfacePing {})
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
            queue.enqueue(&wh.queue, WlShellSurfaceConfigure {})
        },
        popup_done = proc "c" (
            data: rawptr,
            wl_shell_surface: ^wl_shell_surface,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlShellSurfacePopupDone {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlShellSurface)
    res.proxy = proxy
    res.interface = &wl_shell_surface_interface

    res.pong = _pong
    res.move = _move
    res.resize = _resize
    res.set_toplevel = _set_toplevel
    res.set_transient = _set_transient
    res.set_fullscreen = _set_fullscreen
    res.set_popup = _set_popup
    res.set_maximized = _set_maximized
    res.set_title = _set_title
    res.set_class = _set_class
}   


WL_INTERFACE_WL_SURFACE :: "wl_surface"

WlSurface :: struct {
    using base: ^Wl_Base_Interface,


    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    attach : proc "c" (
        proxy: ^wl_proxy,
        buffer : ^wl_buffer,x : c.int32_t,y : c.int32_t
    ) ,

    damage : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t
    ) ,

    frame : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_callback,

    set_opaque_region : proc "c" (
        proxy: ^wl_proxy,
        region : ^wl_region
    ) ,

    set_input_region : proc "c" (
        proxy: ^wl_proxy,
        region : ^wl_region
    ) ,

    commit : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_buffer_transform : proc "c" (
        proxy: ^wl_proxy,
        transform : c.uint32_t
    ) ,

    set_buffer_scale : proc "c" (
        proxy: ^wl_proxy,
        scale : c.int32_t
    ) ,

    damage_buffer : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t
    ) ,

    offset : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t
    ) ,
}

create_wl_surface :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlSurface {
    context = runtime.default_context()
    listener = wl_surface_listener {
        enter = proc "c" (
            data: rawptr,
            wl_surface: ^wl_surface,
            output: ^wl_output,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSurfaceEnter {})
        },
        leave = proc "c" (
            data: rawptr,
            wl_surface: ^wl_surface,
            output: ^wl_output,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSurfaceLeave {})
        },
        preferred_buffer_scale = proc "c" (
            data: rawptr,
            wl_surface: ^wl_surface,
            factor: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSurfacePreferredBufferScale {})
        },
        preferred_buffer_transform = proc "c" (
            data: rawptr,
            wl_surface: ^wl_surface,
            transform: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSurfacePreferredBufferTransform {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlSurface)
    res.proxy = proxy
    res.interface = &wl_surface_interface

    res.destroy = _destroy
    res.attach = _attach
    res.damage = _damage
    res.frame = _frame
    res.set_opaque_region = _set_opaque_region
    res.set_input_region = _set_input_region
    res.commit = _commit
    res.set_buffer_transform = _set_buffer_transform
    res.set_buffer_scale = _set_buffer_scale
    res.damage_buffer = _damage_buffer
    res.offset = _offset
}   


WL_INTERFACE_WL_SEAT :: "wl_seat"

WlSeat :: struct {
    using base: ^Wl_Base_Interface,


    get_pointer : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_pointer,

    get_keyboard : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_keyboard,

    get_touch : proc "c" (
        proxy: ^wl_proxy,
        
    ) ->^wl_touch,

    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_seat :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlSeat {
    context = runtime.default_context()
    listener = wl_seat_listener {
        capabilities = proc "c" (
            data: rawptr,
            wl_seat: ^wl_seat,
            capabilities: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSeatCapabilities {})
        },
        name = proc "c" (
            data: rawptr,
            wl_seat: ^wl_seat,
            name: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlSeatName {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlSeat)
    res.proxy = proxy
    res.interface = &wl_seat_interface

    res.get_pointer = _get_pointer
    res.get_keyboard = _get_keyboard
    res.get_touch = _get_touch
    res.release = _release
}   


WL_INTERFACE_WL_POINTER :: "wl_pointer"

WlPointer :: struct {
    using base: ^Wl_Base_Interface,


    set_cursor : proc "c" (
        proxy: ^wl_proxy,
        serial : c.uint32_t,surface : ^wl_surface,hotspot_x : c.int32_t,hotspot_y : c.int32_t
    ) ,

    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_pointer :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlPointer {
    context = runtime.default_context()
    listener = wl_pointer_listener {
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
            queue.enqueue(&wh.queue, WlPointerEnter {})
        },
        leave = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            serial: c.uint32_t,
            surface: ^wl_surface,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerLeave {})
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
            queue.enqueue(&wh.queue, WlPointerMotion {})
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
            queue.enqueue(&wh.queue, WlPointerButton {})
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
            queue.enqueue(&wh.queue, WlPointerAxis {})
        },
        frame = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerFrame {})
        },
        axis_source = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            axis_source: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerAxisSource {})
        },
        axis_stop = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            time: c.uint32_t,
            axis: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerAxisStop {})
        },
        axis_discrete = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            axis: c.uint32_t,
            discrete: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerAxisDiscrete {})
        },
        axis_value120 = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            axis: c.uint32_t,
            value120: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerAxisValue120 {})
        },
        axis_relative_direction = proc "c" (
            data: rawptr,
            wl_pointer: ^wl_pointer,
            axis: c.uint32_t,
            direction: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlPointerAxisRelativeDirection {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlPointer)
    res.proxy = proxy
    res.interface = &wl_pointer_interface

    res.set_cursor = _set_cursor
    res.release = _release
}   


WL_INTERFACE_WL_KEYBOARD :: "wl_keyboard"

WlKeyboard :: struct {
    using base: ^Wl_Base_Interface,


    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_keyboard :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlKeyboard {
    context = runtime.default_context()
    listener = wl_keyboard_listener {
        keymap = proc "c" (
            data: rawptr,
            wl_keyboard: ^wl_keyboard,
            format: c.uint32_t,
            fd: c.int32_t,
            size: c.uint32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlKeyboardKeymap {})
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
            queue.enqueue(&wh.queue, WlKeyboardEnter {})
        },
        leave = proc "c" (
            data: rawptr,
            wl_keyboard: ^wl_keyboard,
            serial: c.uint32_t,
            surface: ^wl_surface,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlKeyboardLeave {})
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
            queue.enqueue(&wh.queue, WlKeyboardKey {})
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
            queue.enqueue(&wh.queue, WlKeyboardModifiers {})
        },
        repeat_info = proc "c" (
            data: rawptr,
            wl_keyboard: ^wl_keyboard,
            rate: c.int32_t,
            delay: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlKeyboardRepeatInfo {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlKeyboard)
    res.proxy = proxy
    res.interface = &wl_keyboard_interface

    res.release = _release
}   


WL_INTERFACE_WL_TOUCH :: "wl_touch"

WlTouch :: struct {
    using base: ^Wl_Base_Interface,


    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_touch :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlTouch {
    context = runtime.default_context()
    listener = wl_touch_listener {
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
            queue.enqueue(&wh.queue, WlTouchDown {})
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
            queue.enqueue(&wh.queue, WlTouchUp {})
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
            queue.enqueue(&wh.queue, WlTouchMotion {})
        },
        frame = proc "c" (
            data: rawptr,
            wl_touch: ^wl_touch,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlTouchFrame {})
        },
        cancel = proc "c" (
            data: rawptr,
            wl_touch: ^wl_touch,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlTouchCancel {})
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
            queue.enqueue(&wh.queue, WlTouchShape {})
        },
        orientation = proc "c" (
            data: rawptr,
            wl_touch: ^wl_touch,
            id: c.int32_t,
            orientation: wl_fixed_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlTouchOrientation {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlTouch)
    res.proxy = proxy
    res.interface = &wl_touch_interface

    res.release = _release
}   


WL_INTERFACE_WL_OUTPUT :: "wl_output"

WlOutput :: struct {
    using base: ^Wl_Base_Interface,


    release : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_output :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlOutput {
    context = runtime.default_context()
    listener = wl_output_listener {
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
            queue.enqueue(&wh.queue, WlOutputGeometry {})
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
            queue.enqueue(&wh.queue, WlOutputMode {})
        },
        done = proc "c" (
            data: rawptr,
            wl_output: ^wl_output,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlOutputDone {})
        },
        scale = proc "c" (
            data: rawptr,
            wl_output: ^wl_output,
            factor: c.int32_t,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlOutputScale {})
        },
        name = proc "c" (
            data: rawptr,
            wl_output: ^wl_output,
            name: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlOutputName {})
        },
        description = proc "c" (
            data: rawptr,
            wl_output: ^wl_output,
            description: cstring,
        ) {
            // Send message to the queue
            context = runtime.default_context()
            queue.enqueue(&wh.queue, WlOutputDescription {})
        },
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlOutput)
    res.proxy = proxy
    res.interface = &wl_output_interface

    res.release = _release
}   


WL_INTERFACE_WL_REGION :: "wl_region"

WlRegion :: struct {
    using base: ^Wl_Base_Interface,


    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    add : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t
    ) ,

    subtract : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t
    ) ,
}

create_wl_region :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlRegion {
    context = runtime.default_context()
    listener = wl_region_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlRegion)
    res.proxy = proxy
    res.interface = &wl_region_interface

    res.destroy = _destroy
    res.add = _add
    res.subtract = _subtract
}   


WL_INTERFACE_WL_SUBCOMPOSITOR :: "wl_subcompositor"

WlSubcompositor :: struct {
    using base: ^Wl_Base_Interface,


    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    get_subsurface : proc "c" (
        proxy: ^wl_proxy,
        surface : ^wl_surface,parent : ^wl_surface
    ) ->^wl_subsurface,
}

create_wl_subcompositor :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlSubcompositor {
    context = runtime.default_context()
    listener = wl_subcompositor_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlSubcompositor)
    res.proxy = proxy
    res.interface = &wl_subcompositor_interface

    res.destroy = _destroy
    res.get_subsurface = _get_subsurface
}   


WL_INTERFACE_WL_SUBSURFACE :: "wl_subsurface"

WlSubsurface :: struct {
    using base: ^Wl_Base_Interface,


    destroy : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_position : proc "c" (
        proxy: ^wl_proxy,
        x : c.int32_t,y : c.int32_t
    ) ,

    place_above : proc "c" (
        proxy: ^wl_proxy,
        sibling : ^wl_surface
    ) ,

    place_below : proc "c" (
        proxy: ^wl_proxy,
        sibling : ^wl_surface
    ) ,

    set_sync : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,

    set_desync : proc "c" (
        proxy: ^wl_proxy,
        
    ) ,
}

create_wl_subsurface :: proc "contextless" (proxy: ^Wl_Proxy) -> ^WlSubsurface {
    context = runtime.default_context()
    listener = wl_subsurface_listener {
    }
	proxy_add_listener(proxy, cast(^Implementation)&listener, nil)

        res := new(WlSubsurface)
    res.proxy = proxy
    res.interface = &wl_subsurface_interface

    res.destroy = _destroy
    res.set_position = _set_position
    res.place_above = _place_above
    res.place_below = _place_below
    res.set_sync = _set_sync
    res.set_desync = _set_desync
}   


