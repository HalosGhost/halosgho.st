#include "routes.h"

lwan_http_status_t
root_handler (lwan_request_t * req, lwan_response_t * resp, void * data) {

    (void )req; (void )data;

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

