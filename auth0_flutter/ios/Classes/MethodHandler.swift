import Auth0
import Flutter
import JWTDecode

protocol MethodHandler { 
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
}

extension MethodHandler { 
    func result(from credentials: Credentials) -> Any? {
        let jwt: JWT
        do {
            jwt = try decode(jwt: credentials.idToken)
        } catch {
            return FlutterError(from: .idTokenDecodingFailed)
        }
        let data: [String: Any? ] = [
            "accessToken": credentials.accessToken,
            "idToken": credentials.idToken,
            "refreshToken": credentials.refreshToken,
            "userProfile": jwt.body,
            "expiresIn": credentials.expiresIn.timeIntervalSince1970,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
        ]
        return data
    }
}
