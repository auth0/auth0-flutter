/**
 * @file url_utils.cpp
 * @brief Implementation of URL decoding and query parsing utilities
 */

#include "url_utils.h"
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
                    char decoded = (char)strtol(hex.c_str(), nullptr, 16);
                    out.push_back(decoded);
                    i += 2;
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
