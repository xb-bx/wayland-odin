package main

import "core:encoding/xml"
import "core:fmt"
import "core:os"

Arg :: struct {
	name: string,
	type: string,
    interface: string,
}

Event :: struct {
	name: string,
	args: [dynamic]Arg,
}

Interface :: struct {
	name:   string,
	events: [dynamic]Event,
}

type_map := map[string]string{
    "uint" = "c.uint32_t",
    "int" = "c.int32_t",
    "string" = "cstring",
    "object" = "rawptr",
    "fd" = "c.int32_t",
    "new_id" = "c.uint32_t",
    "fixed" = "c.int32_t", // This has some functions that convert from 'fixed' to/from doubles and ints
    "array" = "^wl_array"
};

process_event :: proc(doc: ^xml.Document, interface: ^Interface, index: u32) -> Event{
	event_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	fmt.println("Event", event_name)
	el := doc.elements[index]
    event :=  Event{ name= event_name};

	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			arg_type, _ := xml.find_attribute_val_by_key(doc, val.(u32), "type")

            arg_interface: string = ""
            if arg_type == "object" {
			    arg_interface, _ = xml.find_attribute_val_by_key(doc, val.(u32), "interface")
            }
            append(&event.args, Arg{ name = arg_name, type = arg_type, interface = arg_interface})
		}
	}
    return event;
}

process_interface :: proc(doc: ^xml.Document, el: xml.Element) -> Interface {
	interface := Interface{}

	for attr in el.attribs {
		if attr.key == "name" {
			interface.name = attr.val
		}
	}

	for val in el.value {
		el := doc.elements[val.(u32)]
		if el.ident == "event" {
			append(&interface.events, process_event(doc, &interface, val.(u32)))
		}
	}

    return interface
}

gen_interface_code :: proc(out: os.Handle, interface: Interface) {
    if interface.name != "wl_display" {
        fmt.fprintf(out, "%s :: struct {{}}\n", interface.name)
    }

    fmt.fprintf(out, "%s_listener :: struct {{\n", interface.name);

    for event in interface.events {
        fmt.fprintf(out, "\t%s: proc(\n", event.name);
        fmt.fprintf(out, "\t\tdata: rawptr,\n");
        fmt.fprintf(out, "\t\t%s: ^%s,\n", interface.name, interface.name);

        for arg in event.args {
            if arg.type == "object" && arg.interface != "" {
                fmt.fprintf(out, "\t\t%s: ^%s,\n", arg.name, arg.interface);
            }
            else {
                translated_type, ok := type_map[arg.type]
                if !ok {
                    panic(fmt.tprintf("Unsuported type: interfacer '%s', event '%s', arg_name %s, type '%s'", interface.name, event.name, arg.name, arg.type))
                }
                fmt.fprintf(out, "\t\t%s: %s,\n", arg.name, translated_type);
            }
        }
        fmt.fprintf(out, "\t),\n");
    }

    fmt.fprintf(out, "}}\n\n");
}

// Prolly should use a string builder
main :: proc() {
	out, _ := os.open("wayland/wayland.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, os.S_IRWXU)

    interfaces: [dynamic]Interface;

	fmt.fprintln(out, "package wayland\n")
	fmt.fprintln(out, "import \"core:c\"\n")

	doc, err := xml.load_from_file("wayland.xml")

    // Parse
	for el in doc.elements {
		if (el.ident == "interface") {
		    append(&interfaces, process_interface(doc, el));
		}
	}

    for i in interfaces {
        gen_interface_code(out, i);
    }

    // Write
	os.close(out)
}
