#if !defined(MAIN_H)
#define MAIN_H

#include "common.h"

#pragma once

#define PREFIX "/srv/http"

LWAN_HANDLER_DECLARE(projects);
LWAN_HANDLER_DECLARE(index);

static struct lwan_tpl * page_tpl;

struct page {
    int64_t year;
};

static const struct lwan_var_descriptor page_template[] = {
    TPL_VAR_INT(struct page, year),
    TPL_VAR_SENTINEL
};

#define PRIV_SERVE_FILES(path) \
    .module = LWAN_MODULE_REF(serve_files), \
    .args = &(struct lwan_serve_files_settings ){ \
        .root_path = path, \
        .serve_precompressed_files = true, \
        .auto_index = false \
    } \

static struct lwan_key_value headers [] = {
    { .key = "content-security-policy", .value = "default-src 'self'" },
    { .key = "x-frame-options", .value = "SAMEORIGIN" },
    { .key = "x-xss-protection", .value = "1; mode=block" },
    { .key = "x-content-type-options", .value = "nosniff" },
    { .key = "referrer-policy", .value = "no-referrer" },
    { .key = "expect-ct", .value = "max-age=30, report-uri=\"halosghost.report-uri.com\"" },
    { .key = "strict-transport-security", .value = "max-age=31536000; includeSubDomains" },
    { .key = NULL, .value = NULL }
};

#endif // MAIN_H

