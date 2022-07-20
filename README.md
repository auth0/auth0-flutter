![Stage: Beta Release](https://img.shields.io/badge/stage-beta-orange)
[![CircleCI](https://img.shields.io/circleci/build/github/auth0/auth0-flutter)](https://circleci.com/gh/auth0/auth0-flutter)
[![Codecov](https://img.shields.io/codecov/c/github/auth0/auth0-flutter)](https://codecov.io/gh/auth0/auth0-flutter)

# Auth0 SDK for Flutter (Beta)
TEST DO NOT MERGE
Auth0 SDK for Android / iOS Flutter apps.

> ⚠️ This library is currently in Beta. We do not recommend using this library in production yet. As we move towards First Availaibility, please be aware that releases may contain breaking changes.

| Package                                                                 | Description                                   |
|:------------------------------------------------------------------------|:----------------------------------------------|
| [auth0_flutter](./auth0_flutter/)                                       | SDK for Android / iOS Flutter applications    |
| [auth0_flutter_platform_interface](./auth0_flutter_platform_interface/) | Common interface for platform implementations |

## Features

- Web Auth login and logout
- Authentication API operations:
  + Login with username/email and password
  + Signup
  + Get user information from `/userinfo`
  + Renew credentials
  + Reset password

## Getting Started

See the README of the [auth0_flutter](./auth0_flutter#readme) package.

## Issue Reporting

For general support or usage questions, use the [Auth0 Community](https://community.auth0.com/c/sdks/5) forums or raise a [support ticket](https://support.auth0.com/). Only [raise an issue](https://github.com/auth0/auth0_flutter/issues) if you have found a bug or want to request a feature.

**Do not report security vulnerabilities on the public GitHub issue tracker.** The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

- Add authentication with [multiple sources](https://auth0.com/docs/authenticate/identity-providers), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML Identity Provider**.
- Add authentication through more traditional **[username/password databases](https://auth0.com/docs/authenticate/database-connections/custom-db)**.
- Add support for **[linking different user accounts](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)** with the same user.
- Support for generating signed [JSON Web Tokens](https://auth0.com/docs/secure/tokens/json-web-tokens) to call your APIs and **flow the user identity** securely.
- Analytics of how, when, and where users are logging in.
- Pull data from other sources and add it to the user profile through [JavaScript Actions](https://auth0.com/docs/customize/actions).

**Why Auth0?** Because you should save time, be happy, and focus on what really matters: building your product.

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more information.
