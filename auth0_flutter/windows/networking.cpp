#include "networking.h"

#include <httplib.h>

#include <stdexcept>

namespace auth0_flutter
{

HttpNetworking::HttpNetworking(std::string baseUrl, int timeoutSeconds)
    : baseUrl_(std::move(baseUrl)),
      timeoutSeconds_(timeoutSeconds) {}

NetworkResponse HttpNetworking::post(
    const std::string &path,
    const nlohmann::json &body,
    const std::map<std::string, std::string> &headers)
{
    httplib::Client client(baseUrl_);
    client.set_connection_timeout(timeoutSeconds_, 0);
    client.set_read_timeout(timeoutSeconds_, 0);
    client.set_write_timeout(timeoutSeconds_, 0);

    httplib::Headers httpHeaders;
    for (const auto &[key, value] : headers)
    {
        httpHeaders.emplace(key, value);
    }

    auto res = client.Post(path, httpHeaders, body.dump(), "application/json");

    // cpp-httplib returns a null Result on connection failure (DNS, refused
    // connection, timeout before any response, etc.) instead of throwing like
    // cpprestsdk did — translate that into an exception so callers (e.g.
    // AuthenticationApiClient) can still catch it as a network error.
    if (!res)
    {
        throw std::runtime_error(
            "HTTP request failed: " + httplib::to_string(res.error()));
    }

    return {res->status, nlohmann::json::parse(res->body)};
}

} // namespace auth0_flutter
