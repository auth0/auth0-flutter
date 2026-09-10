#pragma once

#include <string>
#include <map>
#include <memory>
#include <nlohmann/json.hpp>

namespace auth0_flutter
{

struct NetworkResponse
{
    int statusCode;
    nlohmann::json body;
};

class Networking
{
public:
    virtual ~Networking() = default;

    virtual NetworkResponse post(
        const std::string &path,
        const nlohmann::json &body,
        const std::map<std::string, std::string> &headers = {}) = 0;
};

class HttpNetworking : public Networking
{
public:
    HttpNetworking(std::string baseUrl, int timeoutSeconds = 30);

    NetworkResponse post(
        const std::string &path,
        const nlohmann::json &body,
        const std::map<std::string, std::string> &headers = {}) override;

private:
    std::string baseUrl_;
    int timeoutSeconds_;
};

} // namespace auth0_flutter
