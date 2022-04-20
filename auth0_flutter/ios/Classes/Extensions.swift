import Flutter
import Auth0
import JWTDecode

extension Array where Element == String {
    var asSpaceSeparatedString: String {
        return self.joined(separator: " ")
    }
}

extension Dictionary where Key == String {
    subscript<K: RawRepresentable>(_ key: K) -> Value? where K.RawValue == String {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}

extension Date {
    var asISO8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

extension FlutterError {
    convenience init(from handlerError: HandlerError) {
        self.init(code: handlerError.code, message: handlerError.message, details: nil)
    }
}

extension Auth0Error {
    var details: [String: Any]? {
        if let apiError = self as? Auth0APIError {
            var info = apiError.info
            if let cause = cause {
                info["cause"] = String(describing: cause)
            }
            return info
        }
        guard let cause = cause else { return nil }
        return ["cause": String(describing: cause)]
    }
}

extension Auth0APIError {
    var isPasswordLeaked: Bool {
        return self.code == "password_leaked"
    }

    var isLoginRequired: Bool {
        return self.code == "login_required"
    }

    var isNetworkError: Bool {
        return (self.cause as? URLError)?.code == URLError.Code.notConnectedToInternet
    }
}

extension Credentials {
    func asDictionary() throws -> [String: Any] {
        let jwt = try decode(jwt: idToken)
        var data: [String: Any] = [
            CredentialsProperty.accessToken.rawValue: accessToken,
            CredentialsProperty.idToken.rawValue: idToken,
            CredentialsProperty.expiresAt.rawValue: expiresIn.asISO8601String
        ]
        data[CredentialsProperty.refreshToken] = refreshToken
        data[CredentialsProperty.scopes] = scope?.split(separator: " ").map(String.init)
        data[CredentialsProperty.userProfile] = UserInfo(json: jwt.body)?.asDictionary()
        return data
    }
}

extension UserInfo {
    func asDictionary() -> [String: Any] {
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
        var data: [String: Any] = [UserInfoProperty.sub.rawValue: sub]
        data[UserInfoProperty.name] = name
        data[UserInfoProperty.givenName] = givenName
        data[UserInfoProperty.familyName] = familyName
        data[UserInfoProperty.middleName] = middleName
        data[UserInfoProperty.nickname] = nickname
        data[UserInfoProperty.preferredUsername] = preferredUsername
        data[UserInfoProperty.profile] = profile?.absoluteString
        data[UserInfoProperty.picture] = picture?.absoluteString
        data[UserInfoProperty.website] = website?.absoluteString
        data[UserInfoProperty.email] = email
        data[UserInfoProperty.emailVerified] = emailVerified
        data[UserInfoProperty.gender] = gender
        data[UserInfoProperty.birthdate] = birthdate
        data[UserInfoProperty.zoneinfo] = zoneinfo?.identifier
        data[UserInfoProperty.locale] = locale?.identifier
        data[UserInfoProperty.phoneNumber] = phoneNumber
        data[UserInfoProperty.phoneNumberVerified] = phoneNumberVerified
        data[UserInfoProperty.address] = address
        data[UserInfoProperty.updatedAt] = updatedAt?.asISO8601String
        data[UserInfoProperty.customClaims] = customClaims?.filter { !claimsToFilter.contains($0.key) }
        return data
    }
}
