package main

import "core:fmt"


// static inline struct wl_registry *
// wl_display_get_registry(struct wl_display *wl_display)
// {
// 	struct wl_proxy *registry;

// 	registry = wl_proxy_marshal_flags((struct wl_proxy *) wl_display,
// 			 WL_DISPLAY_GET_REGISTRY, &wl_registry_interface, wl_proxy_get_version((struct wl_proxy *) wl_display), 0, NULL);

// 	return (struct wl_registry *) registry;
// }

foreign import lib "system:wayland-client"


wl_list :: struct {
    prev: ^wl_list,
    next: ^wl_list
}

// struct wl_message {
// 	/** Message name */
// 	const char *name;
// 	/** Message signature */
// 	const char *signature;
// 	/** Object argument interfaces */
// 	const struct wl_interface **types;
// };
wl_message :: struct {
    name: cstring,
    signature: cstring,
    types: ^^wl_interface

}
// struct wl_interface {
// 	/** Interface name */
// 	const char *name;
// 	/** Interface version */
// 	int version;
// 	/** Number of methods (requests) */
// 	int method_count;
// 	/** Method (request) signatures */
// 	const struct wl_message *methods;
// 	/** Number of events */
// 	int event_count;
// 	/** Event signatures */
// 	const struct wl_message *events;
// };
wl_interface :: struct {
    name: cstring,
    version: int,
    method_count: int,
    methods: ^wl_message,
    event_count: int,
    events: ^wl_message
}

// struct wl_object {
// 	const struct wl_interface *interface;
// 	const void *implementation;
// 	uint32_t id;
// };
wl_object :: struct {
    interface: ^wl_interface,
    implementation: u64,
    id: u32
}

// struct wl_proxy {
// 	struct wl_object object;
// 	struct wl_display *display;
// 	struct wl_event_queue *queue;
// 	uint32_t flags;
// 	int refcount;
// 	void *user_data;
// 	wl_dispatcher_func_t dispatcher;
// 	uint32_t version;
// 	const char * const *tag;
// 	struct wl_list queue_link; /**< in struct wl_event_queue::proxy_list */
// };

wl_proxy :: struct {
    object: wl_object,
    display: ^wl_display,
    queue: u64, // pointer to wl_event_queue
    flags: u32,
    refcount: int,
    user_data: u64, // void* pointer
    dispatcher: u64, // wl_dispatcher_func_t dispatcher;
    version: u32,
    tag: cstring,
    queue_link: wl_list,
};

// struct wl_display {
// 	struct wl_proxy proxy;
// 	struct wl_connection *connection;

// 	/* errno of the last wl_display error */
// 	int last_error;

// 	/* When display gets an error event from some object, it stores
// 	 * information about it here, so that client can get this
// 	 * information afterwards */
// 	struct {
// 		/* Code of the error. It can be compared to
// 		 * the interface's errors enumeration. */
// 		uint32_t code;
// 		/* interface (protocol) in which the error occurred */
// 		const struct wl_interface *interface;
// 		/* id of the proxy that caused the error. There's no warranty
// 		 * that the proxy is still valid. It's up to client how it will
// 		 * use it */
// 		uint32_t id;
// 	} protocol_error;
// 	int fd;
// 	struct wl_map objects;
// 	struct wl_event_queue display_queue;
// 	struct wl_event_queue default_queue;
// 	pthread_mutex_t mutex;

// 	int reader_count;
// 	uint32_t read_serial;
// 	pthread_cond_t reader_cond;
// };
wl_display :: struct {
    proxy: wl_proxy,
    last_error: int
}

wl_registry :: struct {}

@(default_calling_convention="c")
foreign lib {
    wl_display_connect :: proc(cstring) -> ^wl_display ---
    wl_display_get_registry :: proc(^wl_display) -> ^wl_registry ---
}

main::proc() {
    display := wl_display_connect(nil);
    // registry := wl_display_get_registry(display);

    fmt.println(display);

}
