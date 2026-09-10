#include "auth0_api_client.h"

#include <nlohmann/json.hpp>
#include <windows.h>

#include <sstream>

namespace auth0_flutter
{

// ---------------------------------------------------------------------------
// Telemetry helpers
// ---------------------------------------------------------------------------

static std::string Base64UrlEncode(const std::string &input)
{
    static const char kChars[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string result;
    result.reserve(((input.size() + 2) / 3) * 4);
    for (size_t i = 0; i < input.size(); i += 3)
    {
        unsigned int b = static_cast<unsigned char>(input[i]) << 16;
        if (i + 1 < input.size()) b |= static_cast<unsigned char>(input[i + 1]) << 8;
        if (i + 2 < input.size()) b |= static_cast<unsigned char>(input[i + 2]);
        result += kChars[(b >> 18) & 0x3F];
        result += kChars[(b >> 12) & 0x3F];
        if (i + 1 < input.size()) result += kChars[(b >>  6) & 0x3F];
        if (i + 2 < input.size()) result += kChars[(b      ) & 0x3F];
    }
    // Convert standard base64 to base64url (RFC 4648 §5)
    for (auto &c : result)
    {
        if (c == '+') c = '-';
        else if (c == '/') c = '_';
    }
    // Safety guard: strip padding in case encoding logic changes in the future.
    while (!result.empty() && result.back() == '=') result.pop_back();
    return result;
}

// Returns the real Windows version via RtlGetVersion (avoids GetVersionEx
// compatibility shim lies on Windows 10+). Falls back to "0.0" if ntdll is
// unavailable, which cannot happen in practice since ntdll is always loaded.
static std::string GetWindowsVersion()
{
    OSVERSIONINFOEXW osvi = {};
    osvi.dwOSVersionInfoSize = sizeof(osvi);

    using RtlGetVersionFn = NTSTATUS(WINAPI *)(OSVERSIONINFOEXW *);
    auto *ntdll = ::GetModuleHandleW(L"ntdll.dll");
    if (ntdll)
    {
        auto fn = reinterpret_cast<RtlGetVersionFn>(
            ::GetProcAddress(ntdll, "RtlGetVersion"));
        if (fn) fn(&osvi);
    }

    std::ostringstream oss;
    oss << osvi.dwMajorVersion << "." << osvi.dwMinorVersion;
    return oss.str();
}

std::string BuildAuth0ClientHeader(const std::string &name, const std::string &version)
{
    nlohmann::json env;
    env["Windows"] = GetWindowsVersion();

    nlohmann::json payload;
    payload["name"] = name;
    payload["version"] = version;
    payload["env"] = env;

    return Base64UrlEncode(payload.dump());
}

// ---------------------------------------------------------------------------
// Auth0ApiClient
// ---------------------------------------------------------------------------

Auth0ApiClient::Auth0ApiClient(std::string domain, std::string clientId, std::string auth0ClientHeader)
    : domain_(std::move(domain)),
      clientId_(std::move(clientId)),
      auth0ClientHeader_(std::move(auth0ClientHeader)),
      networking_(std::make_shared<HttpNetworking>("https://" + domain_)) {}

Auth0ApiClient::Auth0ApiClient(std::string domain, std::string clientId, std::string auth0ClientHeader,
                               std::shared_ptr<Networking> networking)
    : domain_(std::move(domain)),
      clientId_(std::move(clientId)),
      auth0ClientHeader_(std::move(auth0ClientHeader)),
      networking_(std::move(networking)) {}

std::map<std::string, std::string> Auth0ApiClient::baseHeaders() const
{
    std::map<std::string, std::string> headers;
    if (!auth0ClientHeader_.empty())
    {
        headers["Auth0-Client"] = auth0ClientHeader_;
    }
    return headers;
}

} // namespace auth0_flutter
