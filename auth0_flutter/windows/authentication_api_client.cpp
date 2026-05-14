#include "authentication_api_client.h"

#include <cpprest/json.h>

#include "token_decoder.h"
#include "authentication_error.h"

using namespace web;

namespace auth0_flutter
{

Credentials AuthenticationApiClient::ExchangeCodeForTokens(
    const std::string &redirectUri,
    const std::string &code,
    const std::string &codeVerifier)
{
    json::value body;
    body[U("grant_type")] = json::value::string(U("authorization_code"));
    body[U("client_id")] = json::value::string(utility::conversions::to_string_t(clientId()));
    body[U("code")] = json::value::string(utility::conversions::to_string_t(code));
    body[U("redirect_uri")] = json::value::string(utility::conversions::to_string_t(redirectUri));
    body[U("code_verifier")] = json::value::string(utility::conversions::to_string_t(codeVerifier));

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
