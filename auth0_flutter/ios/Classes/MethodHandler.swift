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
            "userProfile": jwt.body,
            "expiresAt": expiresAt,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
        ]
        return data
    }
}
