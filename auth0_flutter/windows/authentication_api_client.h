#pragma once

#include <string>
#include <memory>
#include "auth0_api_client.h"
#include "credentials.h"

namespace auth0_flutter
{

class AuthenticationApiClient : public Auth0ApiClient
{
public:
    using Auth0ApiClient::Auth0ApiClient;

    Credentials ExchangeCodeForTokens(
        const std::string &redirectUri,
        const std::string &code,
        const std::string &codeVerifier);
};

} // namespace auth0_flutter
