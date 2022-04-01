import Auth0
import Flutter
import JWTDecode

protocol MethodHandler: Failable {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
}

extension MethodHandler {
    func wrap(result: [String: Any?]?) -> [String: Any?] {
        return ["success": result]
    }

    func result(from credentials: Credentials) -> [String: Any?] {
        let jwt: JWT
        do {
            jwt = try decode(jwt: credentials.idToken)
        } catch { 
            return failure(.idTokenDecodingFailed)
        }
        let resultDictionary: [String: Any?] = [
            "accessToken": credentials.accessToken,
            "idToken": credentials.idToken,
            "refreshToken": credentials.refreshToken,
            "userProfile": jwt.body,
            "expiresIn": credentials.expiresIn.timeIntervalSince1970,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
        ]
        return wrap(result: resultDictionary)
    }
}
