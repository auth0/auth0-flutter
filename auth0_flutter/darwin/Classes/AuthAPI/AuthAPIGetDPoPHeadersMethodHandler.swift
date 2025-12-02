import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIGetDPoPHeadersMethodHandler: MethodHandler {
    enum Argument: String {
        case url
        case method
        case accessToken
        case tokenType
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let urlString = arguments[Argument.url] as? String,
              let url = URL(string: urlString) else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.url.rawValue)))
        }
        guard let method = arguments[Argument.method] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.method.rawValue)))
        }
        guard let accessToken = arguments[Argument.accessToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.accessToken.rawValue)))
        }
        guard let tokenType = arguments[Argument.tokenType] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.tokenType.rawValue)))
        }
        
        let nonce = arguments["nonce"] as? String

        // Create a URLRequest to use with DPoP.addHeaders
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Generate DPoP headers using the static DPoP.addHeaders method
        do {
            try DPoP.addHeaders(to: &request,
                              accessToken: accessToken,
                              tokenType: tokenType,
                              nonce: nonce)
            
            let result: [String: String] = [
                "authorization": request.value(forHTTPHeaderField: "Authorization") ?? "\(tokenType) \(accessToken)",
                "dpop": request.value(forHTTPHeaderField: "DPoP") ?? ""
            ]
            
            callback(result)
        } catch {
            callback(FlutterError(code: "GET_DPOP_HEADERS_ERROR",
                                 message: error.localizedDescription,
                                 details: nil))
        }
    }
}
