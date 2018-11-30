#include "main.h"

signed
main (void) {

    struct lwan l;
    struct lwan_config conf = *lwan_get_default_config();
    conf.listener = "0.0.0.0:8443";
    lwan_init_with_config(&l, &conf);

    //lwan_straitjacket_enforce(&jacket);

    signed errsv = EXIT_SUCCESS;

    errno = 0;
    if ( chdir("pages") ) {
        errsv = errno;
        fprintf(stderr, "Failed to switch to directory `pages`: %s\n", strerror(errsv));
        return EXIT_FAILURE;
    }

    page_tpl = lwan_tpl_compile_file("index.htm", page_template);
    if ( !page_tpl ) {
        fputs("Failed to compile template `index.htm`\n", stderr);
        return EXIT_FAILURE;
    }

    errno = 0;
    if ( chdir(PREFIX) ) {
        errsv = errno;
        fprintf(stderr, "Failed to switch to base directory: %s\n", strerror(errsv));
        return EXIT_FAILURE;
    }

    const struct lwan_url_map default_map [] = {
        { .prefix = "/",         .handler = LWAN_HANDLER_REF(index)    },
        { .prefix = "/assets",   PRIV_SERVE_FILES("./assets")          },
        { .prefix = "/media",    PRIV_SERVE_FILES("./media")           },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);
    lwan_main_loop(&l);
    lwan_tpl_free(page_tpl);
    lwan_shutdown(&l);

    return EXIT_SUCCESS;
}

