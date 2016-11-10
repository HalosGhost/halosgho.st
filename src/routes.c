#include "routes.h"

static signed
proj_list_gen (coro_t * coro) {

    struct projects * proj = coro_get_data(coro);

    size_t len = sizeof proj_list / sizeof(struct project);
    for ( size_t i = 0; i < len; ++ i ) {
        proj->project.name = proj_list[i].name;
        proj->project.url  = proj_list[i].url;
        proj->project.desc = proj_list[i].desc;

        if ( coro_yield(coro, 1) ) { break; }
    } return 0;
}

lwan_http_status_t
root_handler (lwan_request_t * req, lwan_response_t * resp, void * data) {

    (void )req; (void )data;

    const lwan_var_descriptor_t tpl_desc [] = {
        TPL_VAR_SEQUENCE(struct projects, project, proj_list_gen, (
            (const lwan_var_descriptor_t [] ){
                TPL_VAR_STR(struct projects, project.name),
                TPL_VAR_STR(struct projects, project.url),
                TPL_VAR_STR(struct projects, project.desc),
                TPL_VAR_SENTINEL
            }
        )),
        TPL_VAR_SENTINEL
    };

    lwan_tpl_t * tpl = lwan_tpl_compile_file("index.htm.mustache", tpl_desc);
    lwan_tpl_apply_with_buffer(tpl, resp->buffer, &proj_list);
    resp->mime_type = "text/html";
    lwan_tpl_free(tpl);

    return HTTP_OK;
}

