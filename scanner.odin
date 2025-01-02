package main

import "core:encoding/xml"
import "core:fmt"
import "core:os"

Arg :: struct {
	name: string,
	type: string,
}

Event :: struct {
	name: string,
	args: [dynamic]Arg,
}

Interface :: struct {
	name:   string,
	events: [dynamic]Event,
}

process_event :: proc(doc: ^xml.Document, interface: ^Interface, index: u32) {
	event_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	fmt.println("Event", event_name)
	el := doc.elements[index]
	for val in el.value {
		el := doc.elements[val.(u32)]
		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			fmt.println("Arg", arg_name)
		}
	}
}

process_interface :: proc(doc: ^xml.Document, el: xml.Element) {
	interface := Interface{}

	for attr in el.attribs {
		if attr.key == "name" {
			interface.name = attr.val
			// fmt.println(attr.val)
			// fmt.fprintf(out, "%s :: struct {{}}\n", attr.val)
		}
	}

	for val in el.value {
		el := doc.elements[val.(u32)]
		if el.ident == "event" {
			process_event(doc, &interface, val.(u32))
		}
	}
}

// Prolly should use a string builder
main :: proc() {
	out, _ := os.open("wayland/wayland.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, os.S_IRWXU)

	fmt.fprintln(out, "package wayland\n")

	doc, err := xml.load_from_file("wayland.xml")

	for el in doc.elements {
		if (el.ident == "interface") {
			process_interface(doc, el)
		}
	}

	os.close(out)
}
