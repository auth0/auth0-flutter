/**
 * @file url_utils.cpp
 * @brief Implementation of URL decoding and query parsing utilities
 */

#include "url_utils.h"
#include <cstdlib>
#include <sstream>

namespace auth0_flutter
{

    std::string UrlDecode(const std::string &str)
    {
        std::string out;
        out.reserve(str.size());
        for (size_t i = 0; i < str.size(); ++i)
        {
            char c = str[i];
            if (c == '%')
            {
                if (i + 2 < str.size())
                {
                    std::string hex = str.substr(i + 1, 2);
                    char *end = nullptr;
                    long decoded = strtol(hex.c_str(), &end, 16);
                    // Reject invalid hex sequences (strtol consumed nothing)
                    // and null bytes that would truncate C-string APIs.
                    if (end != hex.c_str() + 2 || decoded == 0)
                    {
                        // Malformed or null — skip the percent and emit literally
                        out.push_back(c);
                    }
                    else
                    {
                        out.push_back(static_cast<char>(decoded));
                        i += 2;
                    }
                }
                // else malformed percent-encoding: skip
            }
            else if (c == '+')
            {
                out.push_back(' ');
            }
            else
            {
                out.push_back(c);
            }
        }
        return out;
    }

    std::map<std::string, std::string> SafeParseQuery(const std::string &query)
    {
        std::map<std::string, std::string> params;
        size_t start = 0;
        while (start < query.size())
        {
            size_t eq = query.find('=', start);
            if (eq == std::string::npos)
            {
                break; // no more key=value pairs
            }
            std::string key = query.substr(start, eq - start);
            size_t amp = query.find('&', eq + 1);
            std::string value;
            if (amp == std::string::npos)
            {
                value = query.substr(eq + 1);
                start = query.size();
            }
            else
            {
                value = query.substr(eq + 1, amp - (eq + 1));
                start = amp + 1;
            }
            params[UrlDecode(key)] = UrlDecode(value);
        }
        return params;
    }

} // namespace auth0_flutter
