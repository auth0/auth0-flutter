# Change Log

## [1.0.0-fa.0](https://github.com/auth0/auth0-flutter/tree/1.0.0-fa.0) (2022-07-22)

This is a [First Availability](https://auth0.com/docs/troubleshoot/product-lifecycle/product-release-stages#first-availability) release of the **Auth0 Flutter SDK**! 🎉 

This release includes the addition of a Credentials Manager: a mechanism to manage the tokens returned from Auth0, including the ability to automatically renew the access token when expired (web authentication only). [Read more about the credentials manager](https://github.com/auth0/auth0-flutter/tree/main/auth0_flutter#credentials-manager) in the readme.

## [1.0.0-beta.1](https://github.com/auth0/auth0-flutter/tree/1.0.0-beta.1) (2022-07-08)

This is the first public beta release of the **Auth0 Flutter SDK**! 🎉 

> ⚠️ This release is not yet suitable for use in production

The Auth0 Flutter SDK is a new SDK designed to make it quick and easy to integrate Auth0 into Flutter applications. Today, the SDK offers the following features:

- Support for iOS and Android
- Integration with [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login)
- Integration with the [Auth0 Authentication API](https://auth0.com/docs/api/authentication) for:
  - username and password login
  - signup
  - refreshing access tokens
  - password reset
  - fetching user profile

Check out [the Readme](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/README.md) for a more detailed run through of the capabilities and API.

## [1.0.0-beta.0](https://github.com/auth0/auth0-flutter/tree/1.0.0-beta.0) (2022-05-05)

**Added**

- Web Auth login
- Web Auth logout
- Authenticaiton API login
- Authentication API signup
- Authentication API user profile
- Authentication API renew credentials
- Authentication API reset password
