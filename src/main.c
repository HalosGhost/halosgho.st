#include <lwan/lwan.h>
#include <lwan/lwan-template.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <unistd.h>

static char cwd [PATH_MAX] = { '\0' };

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

    char * resprime = getcwd(cwd, PATH_MAX - 1);
    (void )resprime;

    signed res = chdir("pages");
    (void )res;

    page_tpl = lwan_tpl_compile_file("index.htm", page_template);
    if ( !page_tpl ) {
        fputs("everything's on fire\n", stderr);
    }

    res = chdir(cwd);

    const struct lwan_url_map default_map[] = {
        { .prefix = "/",  .handler = LWAN_HANDLER_REF(index) },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);

    lwan_main_loop(&l);

    lwan_tpl_free(page_tpl);

    lwan_shutdown(&l);
    return EXIT_SUCCESS;
}
