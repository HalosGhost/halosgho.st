#include <lwan/lwan.h>
#include <lwan/lwan-serve-files.h>
#include <lwan/lwan-coro.h>
#include <lwan/lwan-template.h>

static signed
proj_list_gen (coro_t *);

lwan_http_status_t
root_handler (lwan_request_t *, lwan_response_t *, void *);

struct project {
    lwan_tpl_list_generator_t generator;
    const char * name, * url, * desc;
};

struct projects {
    struct project project;
};

static struct project proj_list [] = {
    { .name = "shaman"
    , .url  = "https://github.com/HalosGhost/shaman"
    , .desc = "a simple CLI weather program"
    },
    { .name = "pbpst"
    , .url  = "https://github.com/HalosGhost/pbpst"
    , .desc = "a simple and featureful client for pb deployements"
    }
};

