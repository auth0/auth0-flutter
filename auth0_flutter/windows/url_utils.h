/**
 * @file url_utils.h
 * @brief URL decoding and query parsing utilities
 */

#pragma once

#include <string>
#include <map>

namespace auth0_flutter
{

    /**
     * @brief Decodes a URL-encoded string
     *
     * Handles percent-encoding (%XX) and plus-to-space conversion.
     */
    std::string UrlDecode(const std::string &str);

    /**
     * @brief Safely parses URL query parameters
     *
     * Parses a query string (without leading '?') into a map of key-value pairs.
     * Handles URL-decoded keys and values.
     */
    std::map<std::string, std::string> SafeParseQuery(const std::string &query);

} // namespace auth0_flutter
