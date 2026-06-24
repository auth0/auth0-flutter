#include "networking.h"

#include <cpprest/http_client.h>

using namespace web;
using namespace web::http;
using namespace web::http::client;

namespace auth0_flutter
{

HttpNetworking::HttpNetworking(std::string baseUrl, int timeoutSeconds)
    : baseUrl_(std::move(baseUrl)),
      timeoutSeconds_(timeoutSeconds) {}

NetworkResponse HttpNetworking::post(
    const std::string &path,
    const web::json::value &body,
    const std::map<std::string, std::string> &headers)
{
    http_client_config config;
    config.set_timeout(std::chrono::seconds(timeoutSeconds_));

    http_client client(utility::conversions::to_string_t(baseUrl_), config);

    http_request request(methods::POST);
    request.set_request_uri(utility::conversions::to_string_t(path));
    request.headers().set_content_type(U("application/json"));

    for (const auto &[key, value] : headers)
    {
        request.headers().add(
            utility::conversions::to_string_t(key),
            utility::conversions::to_string_t(value));
    }

    request.set_body(body);

    auto response = client.request(request).get();
    auto json = response.extract_json().get();

    return {response.status_code(), json};
}

} // namespace auth0_flutter
