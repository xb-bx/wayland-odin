# wayland-odin

- [x] Port just enough to call wl_display_get_registry and receive the globals list
- [x] Usable wayland-scanner that ports code to odin.
- [x] Write obligatory cornflower blue example
- [x] Solve shm file allocation bug that makes Hyprland crap its pants
- [ ] Generaty _destroy methods that don't collide with interface 'destroy' methods, check C scanner for this
- [ ] Generate more ergonomic code maybe without cdecl procs
- [ ] Have quality enough to submit as vendor
- [ ] Do not depend on libwayland (if this goes in a really awesome fashion)
