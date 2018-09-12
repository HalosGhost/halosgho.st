#include "common.h"

signed
main (void) {

    struct lwan l;
    lwan_init(&l);

    #define ACMEDIR "/.well-known/acme-challenge"

    const struct lwan_url_map default_map [] = {
        { .prefix = ACMEDIR, SERVE_FILES("." ACMEDIR) },
        { .prefix = "/",  REDIRECT_CODE("https://halosgho.st", HTTP_TEMPORARY_REDIRECT) },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);
    lwan_main_loop(&l);
    lwan_shutdown(&l);

    return EXIT_SUCCESS;
}
