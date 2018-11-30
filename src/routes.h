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

#endif // ROUTES_H

