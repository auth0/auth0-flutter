#include "authentication_api_client.h"

#include <nlohmann/json.hpp>

#include "token_decoder.h"
#include "authentication_error.h"

namespace auth0_flutter
{

Credentials AuthenticationApiClient::ExchangeCodeForTokens(
    const std::string &redirectUri,
    const std::string &code,
    const std::string &codeVerifier)
{
    nlohmann::json body;
    body["grant_type"] = "authorization_code";
    body["client_id"] = clientId();
    body["code"] = code;
    body["redirect_uri"] = redirectUri;
    body["code_verifier"] = codeVerifier;

    try
    {
        auto response = networking().post("/oauth/token", body, baseHeaders());

        if (response.statusCode < 200 || response.statusCode >= 300)
        {
            throw AuthenticationError(response.body, response.statusCode);
        }

        return DecodeTokenResponse(response.body);
    }
    catch (const AuthenticationError &)
    {
        throw;
    }
    catch (const std::exception &e)
    {
        throw AuthenticationError("network_error", e.what(), 0);
    }
}

} // namespace auth0_flutter
