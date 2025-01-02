package main

import "core:encoding/xml"
import "core:fmt"
import "core:os"

process_event :: proc(out: os.Handle, doc: ^xml.Document, el: xml.Element) {
	event_name, _ := xml.find_attribute_val_by_key(doc, el, "name")
	fmt.println(event_name)
}
process_interface :: proc(out: os.Handle, doc: ^xml.Document, el: xml.Element) {
	for attr in el.attribs {
		if attr.key == "name" {
			if attr.val == "wl_display" {
				// ignore this one
				continue
			}
			fmt.println(attr.val)
			fmt.fprintf(out, "%s :: struct {{}}\n", attr.val)
		}
	}

	for val in el.value {
		el := fmt.println(doc.elements[val.(u32)])
		if el.ident == "event" {
			process_event(out, doc, el)
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
			process_interface(out, doc, el)
		}
	}
	os.close(out)
}
