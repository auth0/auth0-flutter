#pragma once
#include <nlohmann/json.hpp>
#include "credentials.h"

Credentials DecodeTokenResponse(
    const nlohmann::json &json);
