import Flutter
import Auth0
import JWTDecode

protocol MethodHandler {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
}

extension MethodHandler {
    func result(from credentials: Credentials) -> Any? {
        let jwt: JWT
        let formatter = ISO8601DateFormatter()
        let expiresAt = formatter.string(from: credentials.expiresIn)
        do {
            jwt = try decode(jwt: credentials.idToken)
        } catch {
            return FlutterError(from: .idTokenDecodingFailed)
        }
        let data: [String: Any?] = [
            "accessToken": credentials.accessToken,
            "idToken": credentials.idToken,
            "refreshToken": credentials.refreshToken,
            "userProfile": filterClaims(jwt.body),
            "expiresAt": expiresAt,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
        ]
        return data
    }

    private func filterClaims(_ claims: [String: Any]) -> [String: Any] {
        let claimsToFilter = ["aud",
                              "iss",
                              "iat",
                              "exp",
                              "nbf",
                              "nonce",
                              "azp",
                              "auth_time",
                              "s_hash",
                              "at_hash",
                              "c_hash"]
        return claims.filter { !claimsToFilter.contains($0.key) }
    }
}
