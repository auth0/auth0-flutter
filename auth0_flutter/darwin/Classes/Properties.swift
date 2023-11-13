enum CredentialsProperty: String, CaseIterable {
    case accessToken
    case idToken
    case userProfile
    case refreshToken
    case expiresAt
    case scopes
    case tokenType
}

enum UserInfoProperty: String, CaseIterable {
    case sub
    case name
    case givenName = "given_name"
    case familyName = "family_name"
    case middleName = "middle_name"
    case nickname
    case preferredUsername = "preferred_username"
    case profile
    case picture
    case website
    case email
    case emailVerified = "email_verified"
    case gender
    case birthdate
    case zoneinfo
    case locale
    case phoneNumber = "phone_number"
    case phoneNumberVerified = "phone_number_verified"
    case address
    case updatedAt = "updated_at"
    case customClaims = "custom_claims"
}
