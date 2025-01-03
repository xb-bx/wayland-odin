package main

import "core:encoding/xml"
import "core:fmt"
import "core:os"

Arg :: struct {
	name:      string,
	type:      string,
	interface: string,
}

Event :: struct {
	name: string,
	args: [dynamic]Arg,
	type: string,
}

Request :: struct {
	name:        string,
	args:        [dynamic]Arg,
	num_new_ids: int,
	opcode:      int,
	type:        string,
}

Interface :: struct {
	name:     string,
	events:   [dynamic]Event,
	requests: [dynamic]Request,
	version:  string,
}

type_map := map[string]string {
	"int"    = "c.int32_t",
	"fd"     = "c.int32_t",
	"new_id" = "c.uint32_t",
	"uint"   = "c.uint32_t",
	"fixed"  = "wl_fixed_t", // This has some functions that convert from 'fixed' to/from doubles and ints
	"string" = "cstring",
	"object" = "rawptr",
	"array"  = "^wl_array",
}

emit_type :: proc(arg: Arg) -> string {
	if arg.type == "object" {
		return fmt.tprintf("^%s", arg.interface)
	}

	return type_map[arg.type]
}

process_event :: proc(doc: ^xml.Document, interface: ^Interface, index: u32) -> Event {
	event_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	event_type, _ := xml.find_attribute_val_by_key(doc, index, "type")
	el := doc.elements[index]
	event := Event {
		name = event_name,
		type = event_type,
	}

	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			arg_type, _ := xml.find_attribute_val_by_key(doc, val.(u32), "type")

			arg_interface, _ := xml.find_attribute_val_by_key(doc, val.(u32), "interface")
			append(&event.args, Arg{name = arg_name, type = arg_type, interface = arg_interface})
		}
	}
	return event
}

process_request :: proc(
	doc: ^xml.Document,
	interface: ^Interface,
	index: u32,
	opcode: int,
) -> Request {
	request_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	request_type, _ := xml.find_attribute_val_by_key(doc, index, "type")
	el := doc.elements[index]
	request := Request {
		name   = request_name,
		opcode = opcode,
		type   = request_type,
	}

	num_new_ids := 0
	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			arg_type, _ := xml.find_attribute_val_by_key(doc, val.(u32), "type")

			if arg_type == "new_id" {
				num_new_ids += 1
			}

			arg_interface, _ := xml.find_attribute_val_by_key(doc, val.(u32), "interface")
			append(&request.args, Arg{name = arg_name, type = arg_type, interface = arg_interface})
		}
	}
	request.num_new_ids = num_new_ids
	return request
}


process_interface :: proc(doc: ^xml.Document, el: xml.Element) -> Interface {
	interface := Interface{}

	for attr in el.attribs {
		if attr.key == "name" {
			interface.name = attr.val
		}
		if attr.key == "version" {
			interface.version = attr.val
		}
	}

	// Opcodes are defined by spec order, just increment it for every request processed
	opcode := 0
	for val in el.value {
		el := doc.elements[val.(u32)]
		if el.ident == "event" {
			append(&interface.events, process_event(doc, &interface, val.(u32)))
		}
		if el.ident == "request" {
			append(&interface.requests, process_request(doc, &interface, val.(u32), opcode))
			opcode += 1
		}
	}

	return interface
}

emit_interface_code :: proc(out: os.Handle, interface: Interface) {
	emit_structs(out, interface)
	emit_listeners(out, interface)
	emit_request_stubs(out, interface)
	emit_private_code(out, interface)
}
emit_structs :: proc(out: os.Handle, interface: Interface) {
	if interface.name != "wl_display" {
		fmt.fprintf(out, "%s :: struct {{}}\n", interface.name)
	}

}

emit_listeners :: proc(out: os.Handle, interface: Interface) {
	fmt.fprintf(out, "%s_listener :: struct {{\n", interface.name)

	// Generate listener code based on interface event
	for event in interface.events {
		// Start proc definition
		fmt.fprintf(out, "\t%s: proc(\n", event.name)

		// Add default arg of user data and interface pointer
		fmt.fprintf(out, "\t\tdata: rawptr,\n")
		fmt.fprintf(out, "\t\t%s: ^%s,\n", interface.name, interface.name)

		// Add spec args
		for arg in event.args {
			if arg.type == "object" && arg.interface != "" {
				fmt.fprintf(out, "\t\t%s: ^%s,\n", arg.name, arg.interface)
			} else {
				translated_type, ok := type_map[arg.type]
				if !ok {
					panic(
						fmt.tprintf(
							"Unsuported type: interface '%s', event '%s', arg_name %s, type '%s'",
							interface.name,
							event.name,
							arg.name,
							arg.type,
						),
					)
				}
				fmt.fprintf(out, "\t\t%s: %s,\n", arg.name, translated_type)
			}
		}
		fmt.fprintf(out, "\t),\n")
	}
	// Close proc declaration
	fmt.fprintf(out, "}}\n\n")

	// Generate *_add_listener proc for each interface
	//FIXME(quadrado): Remove auto cast from here when you have a fking idea how *void**(**)* works, or whatever
	template := `%s_add_listener :: proc(
    %s: ^%s,
    listener: ^%s_listener,
    data: rawptr,
) -> c.int {{

    return proxy_add_listener(cast(^wl_proxy)%s, auto_cast listener, data)
}};

`
	fmt.fprintf(
		out,
		template,
		interface.name,
		interface.name,
		interface.name,
		interface.name,
		interface.name,
	)
}

emit_request_stubs :: proc(out: os.Handle, interface: Interface) {
	// Generate requests code on interface requests
	// This is mostly a verbatim port of the original scanner.c code
	for request in interface.requests {
		if request.num_new_ids > 1 {
			fmt.println("Not generating stub for {request.name}. new_ids > 1")
			continue
		}
		ret: ^Arg = nil
		ret_string: string = ""

		// Find return argument
		for &arg in request.args {
			if arg.type == "new_id" {
				ret = &arg
				break
			}
		}

		// Calculate return type string
		if ret == nil {
			ret_string = ""
		} else if ret != nil && ret.interface == "" {
			ret_string = "rawptr"
		} else {
			ret_string = fmt.tprintf("^%s", ret.interface)
		}

		// Emit proc header start with default first argument
		fmt.fprintf(
			out,
			"%s_%s :: proc(%s: ^%s",
			interface.name,
			request.name,
			interface.name,
			interface.name,
		)

		// Emit the other args with the not documented "interface == null" edge-case...
		for &arg in request.args {
			if arg.type == "new_id" && arg.interface == "" {
				fmt.fprintf(out, ", interface: ^wl_interface, version: c.uint32_t")
				continue
			} else if arg.type == "new_id" {
				continue
			}
			fmt.fprintf(out, ",%s : %s", arg.name, emit_type(arg))
		}

		// Close proc header and add return type
		fmt.fprintf(out, ")")
		if ret != nil {
			fmt.fprintf(out, "-> %s ", ret_string)
		} else {
			fmt.fprintf(out, "\n")
		}

		// Proc body start
		fmt.fprintf(out, "{{\n")

		// Proc body code
		if ret != nil {
			fmt.fprintf(out, "\t%s: ^wl_proxy\n\t%s = ", ret.name, ret.name)
		}

		fmt.fprintf(
			out,
			`proxy_marshal_flags(
                cast(^wl_proxy)%s,
		        %d`,
			interface.name,
			request.opcode,
		)

		if ret != nil {
			if ret.interface != "" {
				//         /* Normal factory case, an arg has type="new_id" and
				//          * an interface is provided */
				fmt.fprintf(out, ", &%s_interface", ret.interface)
			} else {
				//         /* an arg has type ="new_id" but interface is not
				//          * provided, such as in wl_registry.bind */
				fmt.fprintf(out, ", interface")
			}
		} else {
			//     /* No args have type="new_id" */
			fmt.fprintf(out, ", nil")
		}

		if ret != nil && ret.interface == "" {
			fmt.fprintf(out, ", version")
		} else {
			fmt.fprintf(out, ", proxy_get_version(cast(^wl_proxy)%s)", interface.name)
		}
		fmt.fprintf(out, ", %s", request.type == "destructor" ? "WL_MARSHAL_FLAG_DESTROY" : "0")

		for arg in request.args {
			if (arg.type == "new_id") {
				if (arg.interface == "") {
					fmt.fprintf(out, ", interface.name, version")
				}
				fmt.fprintf(out, ", nil")
			} else {
				fmt.fprintf(out, ", %s", arg.name)
			}
		}

		fmt.fprintf(out, ");\n\n")


		if (ret != nil && ret.interface == "") {
			fmt.fprintf(out, "\n\treturn cast(rawptr)%s;\n", ret.name)
		} else if (ret != nil) {
			fmt.fprintf(out, "\n\treturn cast(^%s)%s;\n", ret.interface, ret.name)
		}

		// Proc body end
		fmt.fprintf(out, "}}\n\n")
	}
}

emit_args_string :: proc(out: os.Handle, args: [dynamic]Arg) {
	for arg in args {
		// if (is_nullable_type(a) && a->nullable)
		//     printf("?");

		switch (arg.type) {
		case "int":
			fmt.fprintf(out, "i")
		case "new_id":
			if (arg.interface == "") {
				fmt.fprintf(out, "su")
			}
			fmt.fprintf(out, "n")
		case "unsigned":
			fmt.fprintf(out, "u")
		case "fixed":
			fmt.fprintf(out, "f")
		case "string":
			fmt.fprintf(out, "s")
		case "object":
			fmt.fprintf(out, "o")
		case "array":
			fmt.fprintf(out, "a")
		case "fd":
			fmt.fprintf(out, "h")
		}
	}
}

emit_events_message :: proc(out: os.Handle, event: Event) {
	fmt.fprintf(out, "\t{{ \"%s\", \"", event.name)
	emit_args_string(out, event.args)
	fmt.println(event.args)
	fmt.fprintf(out, "\", nil }},\n")
}

emit_private_code :: proc(out: os.Handle, interface: Interface) {
	// Events struct
	fmt.fprintf(out, "%s_events: []wl_message = []wl_message{{\n", interface.name)
	for event in interface.events {
		emit_events_message(out, event)
	}
	fmt.fprintf(out, "}}\n\n")

	// Interface struct
	fmt.fprintf(out, "%s_interface: wl_interface = wl_interface{{\n", interface.name)
	fmt.fprintf(out, "\t\"%s\",\n", interface.name)
	fmt.fprintf(out, "\t%s,\n", interface.version)
	fmt.fprintf(out, "\t%d,\n", len(interface.requests))
	fmt.fprintf(out, "\t{{}},\n")
	fmt.fprintf(out, "\t%d,\n", len(interface.events))
	fmt.fprintf(out, "\t&%s_events[0],\n", interface.name)
	fmt.fprintf(out, "}}\n\n")
}

// Prolly should use a string builder
main :: proc() {
	out, _ := os.open("wayland/wayland.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, os.S_IRWXU)

	interfaces: [dynamic]Interface

	fmt.fprintln(out, "package wayland\n")
	fmt.fprintln(out, "import \"core:c\"\n")

	doc, err := xml.load_from_file("wayland.xml")

	// Parse
	for el in doc.elements {
		if (el.ident == "interface") {
			append(&interfaces, process_interface(doc, el))
		}
	}

	for i in interfaces {
		emit_interface_code(out, i)
	}

	// Write
	os.close(out)
}
