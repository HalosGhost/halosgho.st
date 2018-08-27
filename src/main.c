#include <lwan/lwan.h>
#include <lwan/lwan-template.h>
#include <lwan/lwan-mod-serve-files.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>

#define PRIV_SERVE_FILES(path) \
    .module = LWAN_MODULE_REF(serve_files), \
    .args = &(struct lwan_serve_files_settings ){ \
        .root_path = path, \
        .serve_precompressed_files = true, \
        .auto_index = false \
    } \

struct page {
    int64_t year;
};

static const struct lwan_var_descriptor page_template[] = {
    TPL_VAR_INT(struct page, year),
    TPL_VAR_SENTINEL
};

static struct lwan_tpl * page_tpl;

LWAN_HANDLER(index) {

    time_t thetime = time(NULL);
    struct tm * t = localtime(&thetime);
    struct page pg = {
        .year = t->tm_year + 1900,
    };

    response->mime_type = "text/html; charset=UTF-8";
    response->headers = (struct lwan_key_value [] ){
        { .key = "content-security-policy", .value = "default-src 'self'" },
        { .key = "x-frame-options", .value = "SAMEORIGIN" },
        { .key = "x-xss-protection", .value = "1; mode=block" },
        { .key = "x-content-type-options", .value = "nosniff" },
        { .key = "referrer-policy", .value = "no-referrer" },
    };

    lwan_tpl_apply_with_buffer(page_tpl, response->buffer, &pg);

    return HTTP_OK;
}

signed
main (void) {

    struct lwan l;
    lwan_init(&l);

    signed errsv = EXIT_SUCCESS;

    char cwd [PATH_MAX] = { '\0' };
    errno = 0;
    if ( !getcwd(cwd, PATH_MAX - 1) ) {
        errsv = errno;
        fprintf(stderr, "Failed to save base directory: %s\n", strerror(errsv));
        return EXIT_FAILURE;
    }

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
    if ( chdir(cwd) ) {
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
