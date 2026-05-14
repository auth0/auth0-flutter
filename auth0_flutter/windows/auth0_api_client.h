#pragma once

#include <string>
#include <map>
#include <memory>

#include "networking.h"

namespace auth0_flutter
{

class Auth0ApiClient
{
public:
    Auth0ApiClient(std::string domain, std::string clientId, std::string auth0ClientHeader);

    Auth0ApiClient(std::string domain, std::string clientId, std::string auth0ClientHeader,
                   std::shared_ptr<Networking> networking);

    virtual ~Auth0ApiClient() = default;

    const std::string &domain() const { return domain_; }
    const std::string &clientId() const { return clientId_; }

protected:
    Networking &networking() { return *networking_; }

    std::map<std::string, std::string> baseHeaders() const;

private:
    // Order matters: domain_ must precede networking_ because the initializer
    // list constructs networking_ from domain_ (use-after-move safety).
    std::string domain_;
    std::string clientId_;
    std::string auth0ClientHeader_;
    std::shared_ptr<Networking> networking_;
};

std::string BuildAuth0ClientHeader(const std::string &name, const std::string &version);

} // namespace auth0_flutter
