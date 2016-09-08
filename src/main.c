#include "main.h"

signed
main (void) {

    const lwan_url_map_t route_table [] = {
        { .prefix = "/",       .handler = root_handler },
//        { .prefix = "/assets", SERVE_FILES("./assets") },
        { .prefix = 0,         .handler = 0            }
    };

    lwan_t l;
    lwan_init(&l);
    lwan_set_url_map(&l, route_table);

    lwan_main_loop(&l);

    lwan_shutdown(&l);
    return EXIT_SUCCESS;
}

// vim: set ts=4 sw=4 et:
