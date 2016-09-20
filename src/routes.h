#include <lwan/lwan.h>
#include <lwan/lwan-serve-files.h>
#include <lwan/lwan-coro.h>
#include <lwan/lwan-template.h>

static signed
proj_list_gen (coro_t *);

lwan_http_status_t
root_handler (lwan_request_t *, lwan_response_t *, void *);

struct project {
    const char * name, * url, * desc;
};

