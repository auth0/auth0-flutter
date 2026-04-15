#pragma once
#include <cpprest/json.h>
#include "credentials.h"

Credentials DecodeTokenResponse(
    const web::json::value &json);
