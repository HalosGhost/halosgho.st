#include "common.h"

signed
main (void) {

    struct lwan l;
    struct lwan_config conf = *lwan_get_default_config();
    conf.listener = "0.0.0.0:8080";
    lwan_init_with_config(&l, &conf);

    lwan_straitjacket_enforce(&jacket);

    #define ACMEDIR "/.well-known/acme-challenge"

    char * target = getenv("HOMEPAGE_REDIRECT_TARGET");
    if ( !target ) {
        fputs("ERROR: No target specified in HOMEPAGE_REDIRECT_TARGET\n", stderr);
        goto cleanup;
    }

    const struct lwan_url_map default_map [] = {
        { .prefix = ACMEDIR, PRIV_SERVE_FILES("." ACMEDIR) },
        { .prefix = "/",  REDIRECT_CODE(target, HTTP_TEMPORARY_REDIRECT) },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);
    lwan_main_loop(&l);

    cleanup:
        lwan_shutdown(&l);
        return EXIT_SUCCESS;
}
