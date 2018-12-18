#if !defined(MAIN_H)
#define MAIN_H

#pragma once

#include "common.h"

static struct lwan_tpl * index_tpl;

struct index {
    int64_t year;
};

static const struct lwan_var_descriptor index_template[] = {
    TPL_VAR_INT(struct index, year),
    TPL_VAR_SENTINEL
};

static struct lwan_key_value headers [] = {
    { .key = "content-security-policy", .value = "default-src 'self'" },
    { .key = "x-frame-options", .value = "SAMEORIGIN" },
    { .key = "x-xss-protection", .value = "1; mode=block" },
    { .key = "x-content-type-options", .value = "nosniff" },
    { .key = "referrer-policy", .value = "no-referrer" },
    { .key = "strict-transport-security", .value = "max-age=31536000; includeSubDomains" },
    { .key = NULL, .value = NULL }
};

#include "routes.h"

#endif // MAIN_H

