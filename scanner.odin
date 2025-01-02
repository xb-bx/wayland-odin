package main

import "core:encoding/xml"
import "core:fmt"
import "core:os"

main :: proc() {
	out, _ := os.open("wayland/wayland.odin", os.O_CREATE | os.O_TRUNC | os.O_RDWR, os.S_IRWXU)

	fmt.fprintln(out, "package wayland\n")

	doc, err := xml.load_from_file("wayland.xml")

	for el in doc.elements {
		if (el.ident == "interface") {
			// fmt.println(el);
			for attr in el.attribs {
				if attr.key == "name" {
					fmt.println(attr.val)
					fmt.fprintf(out, "%s :: struct {{}}\n", attr.val)
				}
			}
		}
	}
	os.close(out)
}
