package render

import "core:fmt"
import "vendor:egl"


init_egl :: proc() {
	major, minor, count, n, size: i32
	configs: []egl.Config
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
	egl_display := egl.GetDisplay(egl.DEFAULT_DISPLAY)
	if (egl_display == egl.NO_DISPLAY) {
		fmt.println("Can't create egl display\n")
	} else {
		fmt.println("Created egl display\n")
	}
	if (egl.Initialize(egl_display, &major, &minor)) {

		fmt.println("Can't initialise egl display\n")
	}
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
