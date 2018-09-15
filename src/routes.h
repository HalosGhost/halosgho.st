#if !defined(ROUTES_H)
#define ROUTES_H

#pragma once

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

LWAN_HANDLER(projects) {

    const char * name = lwan_request_get_query_param(request, "name");
    if ( name ) {
        lwan_strbuf_set_static(response->buffer, name, strlen(name));
    } else {
        lwan_strbuf_set_static(response->buffer, "index", 5);
    }

    response->mime_type = "text/plain";
    response->headers = headers;

    return HTTP_OK;
}

#endif // ROUTES_H

