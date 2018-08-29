#include "main.h"

LWAN_HANDLER(index) {

    time_t thetime = time(NULL);
    struct tm * t = localtime(&thetime);
    struct page pg = {
        .year = t->tm_year + 1900,
    };

    response->mime_type = "text/html; charset=UTF-8";
    response->headers = headers;

    lwan_tpl_apply_with_buffer(page_tpl, response->buffer, &pg);

    return HTTP_OK;
}

signed
main (void) {

    struct lwan l;
    lwan_init(&l);

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
        { .prefix = "/",  .handler = LWAN_HANDLER_REF(index) },
        { .prefix = "/assets", PRIV_SERVE_FILES("./assets") },
        { .prefix = "/media", PRIV_SERVE_FILES("./media") },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);
    lwan_main_loop(&l);
    lwan_tpl_free(page_tpl);
    lwan_shutdown(&l);

    return EXIT_SUCCESS;
}
