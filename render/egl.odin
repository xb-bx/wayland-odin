package render

import wl "../wayland"
import "core:c"
import "core:fmt"
import "vendor:egl"

foreign import foo "system:EGL"

@(default_calling_convention = "c", link_prefix = "egl")
foreign foo {
	GetError :: proc() -> i32 ---
}

EGL_BAD_DISPLAY :: 0x3008

//m_pEglDisplay = m_sProc.eglGetPlatformDisplayEXT(
//	gbm ? EGL_PLATFORM_GBM_KHR : EGL_PLATFORM_DEVICE_EXT,
//	gbm ? m_pGbmDevice : m_pEglDevice,
//	attrs.data(),
//)

// // loadGLProc(&m_sProc.eglGetPlatformDisplayEXT, "eglGetPlatformDisplayEXT");
eglGetPlatformDisplayEXT :: proc "c" (
	platform: int,
	native_display: rawptr,
	attrib_list: [^]c.int,
) -> egl.Display

EGL_PLATFORM_DEVICE_EXT :: 0x313F
EGL_PLATFORM_GBM_KHR :: 12759


init :: proc() {
	using egl

	major, minor: i32
	attrib_list: [^]c.int
	config_attribs: []i32 = {
		egl.SURFACE_TYPE,
		egl.SURFACE_TYPE,
		egl.WINDOW_BIT,
		egl.RED_SIZE,
		1,
		egl.GREEN_SIZE,
		1,
		egl.BLUE_SIZE,
		1,
		egl.RENDERABLE_TYPE,
		egl.OPENGL_ES2_BIT,
		egl.NONE,
	}
	configs: [^]egl.Config
	context_attribs: []i32 = {egl.CONTEXT_CLIENT_VERSION, 2, egl.NONE}

	getdisplay: eglGetPlatformDisplayEXT

	egl.gl_set_proc_address(&getdisplay, "eglGetPlatformDisplayEXT")
	egl_display := getdisplay(EGL_PLATFORM_GBM_KHR, DEFAULT_DISPLAY, attrib_list)
	fmt.println(egl_display)
	if (egl_display == egl.NO_DISPLAY) {
		fmt.println("Can't create egl display")
	} else {
		fmt.println("Created egl display")
	}
	if (!egl.Initialize(egl_display, &major, &minor)) {
		fmt.println("Can't initialise egl display")
		fmt.printf("Error code: 0x%x\n", GetError())
	}
	n: i32 = 0
	fmt.printf("EGL major: %d, minor %d\n", major, minor)
	res := egl.ChooseConfig(egl_display, attrib_list, configs, 20, &n)
	fmt.printf("Num configs : %d\n", n)
	fmt.println(configs)
}

init_egl :: proc(display: ^wl.wl_display) {
	major, minor, n, size: i32
	count: i32 = 0
	configs: []egl.Config
	egl_conf: egl.Config
	i: int
	config_attribs: []i32 = {
		egl.SURFACE_TYPE,
		egl.SURFACE_TYPE,
		egl.WINDOW_BIT,
		egl.RED_SIZE,
		8,
		egl.GREEN_SIZE,
		8,
		egl.BLUE_SIZE,
		8,
		egl.RENDERABLE_TYPE,
		egl.OPENGL_ES2_BIT,
		egl.NONE,
	}
	context_attribs: []i32 = {egl.CONTEXT_CLIENT_VERSION, 2, egl.NONE}
	egl_display := egl.GetDisplay(egl.NativeDisplayType(display))

	if (egl_display == egl.NO_DISPLAY) {
		fmt.println("Can't create egl display")
	} else {
		fmt.println("Created egl display")
	}
	if (!egl.Initialize(egl_display, nil, nil)) {

		fmt.println("Can't initialise egl display")
		fmt.printf("Error code: 0x%x\n", GetError())
	}
	fmt.printf("EGL major: %d, minor %d\n", major, minor)
	// GetConfigs() doesn't exist in vendor:egl
	//egl.GetConfigs(egl_display, nil, 0, &count)
	//fmt.printf("EGL has %d configs\n", count)

	//     configs = calloc(count, sizeof *configs);

	res := egl.ChooseConfig(egl_display, raw_data(config_attribs), raw_data(configs), count, &n)
	fmt.printf("%x\n", GetError())
	if res == egl.FALSE {
	}
	fmt.println(res, n)

	for i in 0 ..< n {
		egl.GetConfigAttrib(egl_display, configs[i], 12320, &size) // 12320 is EGL_BUFFER_SIZE
		fmt.printf("Buffer size for config %d is %d\n", i, size)
		egl.GetConfigAttrib(egl_display, configs[i], egl.RED_SIZE, &size)
		fmt.printf("Red size for config %d is %d\n", i, size)

		// just choose the first one
		egl_conf = configs[i]
		break
	}

	//     egl_context =
	// 	eglCreateContext(egl_display,
	// 			 egl_conf,
	// 			 EGL_NO_CONTEXT, context_attribs);

}
// init_egl() {

//     EGLint major, minor, count, n, size;
//     EGLConfig *configs;
//     int i;
//     EGLint config_attribs[] = {
// 	EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
// 	EGL_RED_SIZE, 8,
// 	EGL_GREEN_SIZE, 8,
// 	EGL_BLUE_SIZE, 8,
// 	EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
// 	EGL_NONE
//     };

//     static const EGLint context_attribs[] = {
// 	EGL_CONTEXT_CLIENT_VERSION, 2,
// 	EGL_NONE
//     };


//     egl_display = eglGetDisplay((EGLNativeDisplayType) display);
//     if (egl_display == EGL_NO_DISPLAY) {
// 	fprintf(stderr, "Can't create egl display\n");
// 	exit(1);
//     } else {
// 	fprintf(stderr, "Created egl display\n");
//     }

//     if (eglInitialize(egl_display, &major, &minor) != EGL_TRUE) {
// 	fprintf(stderr, "Can't initialise egl display\n");
// 	exit(1);
//     }
//     printf("EGL major: %d, minor %d\n", major, minor);

//     eglGetConfigs(egl_display, NULL, 0, &count);
//     printf("EGL has %d configs\n", count);

//     configs = calloc(count, sizeof *configs);

//     eglChooseConfig(egl_display, config_attribs,
// 			  configs, count, &n);

//     for (i = 0; i < n; i++) {
// 	eglGetConfigAttrib(egl_display,
// 			   configs[i], EGL_BUFFER_SIZE, &size);
// 	printf("Buffer size for config %d is %d\n", i, size);
// 	eglGetConfigAttrib(egl_display,
// 			   configs[i], EGL_RED_SIZE, &size);
// 	printf("Red size for config %d is %d\n", i, size);

// 	// just choose the first one
// 	egl_conf = configs[i];
// 	break;
//     }

//     egl_context =
// 	eglCreateContext(egl_display,
// 			 egl_conf,
// 			 EGL_NO_CONTEXT, context_attribs);

// }
