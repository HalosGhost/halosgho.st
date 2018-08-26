#include <lwan/lwan.h>
#include <lwan/lwan-template.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <unistd.h>

static char cwd [PATH_MAX] = { '\0' };

struct page {
    //char * url, * name, * desc;
    int64_t year;
};

static const struct lwan_var_descriptor page_template[] = {
    //TPL_VAR_STR_ESCAPE(struct page, url),
    //TPL_VAR_STR_ESCAPE(struct page, name),
    //TPL_VAR_STR_ESCAPE(struct page, desc),
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
    lwan_tpl_apply_with_buffer(page_tpl, response->buffer, &pg);

    return HTTP_OK;
}

//LWAN_HANDLER(mustache) {
//
//
    //FILE * f = fopen("index.htm", "r");
//
    //fseek(f, 0l, SEEK_END);
    //size_t size = (size_t )ftell(f);
    //fseek(f, 0l, SEEK_SET);
//
    //char * msg = malloc(size);
    //size_t res = fread(msg, size, 1, f);
    //(void )res;
//
    //response->mime_type = "text/html; charset=UTF-8";
    //lwan_strbuf_set_static(response->buffer, msg, size);
//
    //return HTTP_OK;
//}

LWAN_HANDLER(assets) {

    signed res = chdir("assets");
    (void )res;

    lwan_strbuf_set_static(response->buffer, "stuff", 5);
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
        //{ .prefix = "/assets", .handler = LWAN_HANDLER_REF(assets) },
        { .prefix = NULL }
    };

    lwan_set_url_map(&l, default_map);

    lwan_main_loop(&l);

    lwan_tpl_free(page_tpl);

    lwan_shutdown(&l);
    return EXIT_SUCCESS;
}
