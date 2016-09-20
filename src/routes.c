#include "routes.h"

static signed
proj_list_gen (coro_t * coro) {

    struct project * proj = coro_get_data(coro);

    struct project proj_list [] = {
        { "shaman",
          "https://github.com/HalosGhost/shaman",
          "a simple CLI weather program",
        },
        { "pbpst",
          "https://github.com/HalosGhost/pbpst",
          "a simple and featureful client for pb deployements",
        }
    };

    size_t len = sizeof proj_list / sizeof(struct project);
    for ( size_t i = 0; i < len; ++ i ) {
        proj->name = proj_list[i].name;
        proj->url  = proj_list[i].url;
        proj->desc = proj_list[i].desc;

        if ( coro_yield(coro, 1) ) { break; }
    }

    return 0;
}

lwan_http_status_t
root_handler (lwan_request_t * req, lwan_response_t * resp, void * data) {

    (void )req; (void )data;

    const lwan_var_descriptor_t tpl_desc [] = {
        TPL_VAR_SEQUENCE(struct project, proj_list, proj_list_gen, (
            (const lwan_var_descriptor_t [] ){
                TPL_VAR_STR(struct project, name),
                TPL_VAR_STR(struct project, url),
                TPL_VAR_STR(struct project, desc),
                TPL_VAR_SENTINEL
            }
        )),
        TPL_VAR_SENTINEL
    };

    lwan_tpl_compile_file("index.htm.mustache", tpl_desc);

    const char msg [] =
      "<!DOCTYPE html>"
      "<html>"
        "<head><title>/home/halosghost</title></head>"
        "<body><h1>Sam Stuewe (HalosGhost)</h1></body>"
      "</html>";

    resp->mime_type = "text/html";
    strbuf_set_static(resp->buffer, msg, sizeof(msg) - 1);

    return HTTP_OK;
}

