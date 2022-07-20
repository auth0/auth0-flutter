# Auth0 Flutter SDK: Example

Flutter app for Android / iOS that demonstrates how to use the Auth0 Flutter SDK.

## Configuration

### 1. Configure Auth0 Application

Go to the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/) and add the corresponding URLs to **Allowed Callback URLs** and **Allowed Logout URLs**, according to the platforms used by your app. If you are using a [Custom Domain](https://auth0.com/docs/brand-and-customize/custom-domains), replace `YOUR_AUTH0_DOMAIN` with the value of your Custom Domain instead of the value from the settings page.

#### Android

```text
https://YOUR_AUTH0_DOMAIN/android/YOUR_APP_PACKAGE_NAME/callback
```

E.g. if your Auth0 Domain was `company.us.auth0.com` and your Android app package name was `com.company.myapp`, then this value would be:

```text
https://company.us.auth0.com/android/com.company.myapp/callback
```

#### iOS

```text
YOUR_BUNDLE_IDENTIFIER://YOUR_AUTH0_DOMAIN/ios/YOUR_BUNDLE_IDENTIFIER/callback
```

E.g. if your iOS bundle identifier was `com.company.myapp` and your Auth0 Domain was `company.us.auth0.com`, then this value would be:

```text
com.company.myapp://company.us.auth0.com/ios/com.company.myapp/callback
```

### 2. Configure Flutter app

Rename the `.env.example` file to `.env`. Then, open it and fill in the values:

- `AUTH0_DOMAIN`: your Auth0 Domain, e.g. `company.us.auth0.com`.
- `AUTH0_CLIENT_ID`: the Client Id of your Auth0 application, available in its [settings page](https://manage.auth0.com/#/applications/).

### 3. Configure Android project

Copy the `android/app/src/main/res/values/strings.xml.example` file into a new file called `strings.xml` in the same folder. This new file is ignored by Git.

Open the `strings.xml` file and replace `YOUR_AUTH0_DOMAIN` with your own value, e.g. `company.us.auth0.com`. This value will be passed to the respective manifest placeholder.

Configure the `com_auth0_scheme` entry with the correct value, if you require a custom scheme.

## What is Auth0?

Auth0 helps you to:

- Add authentication with [multiple sources](https://auth0.com/docs/authenticate/identity-providers), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML identity provider**.
- Add authentication through more traditional **[username/password databases](https://auth0.com/docs/authenticate/database-connections/custom-db)**.
- Add support for **[linking different user accounts](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)** with the same user.
- Support for generating signed [JSON web tokens](https://auth0.com/docs/secure/tokens/json-web-tokens) to call your APIs and **flow the user identity** securely.
- Analytics of how, when, and where users are logging in.
- Pull data from other sources and add it to the user profile through [JavaScript Actions](https://auth0.com/docs/customize/actions).

**Why Auth0?** Because you should save time, be happy, and focus on what really matters: building your product.

## License

This project is licensed under the MIT license. See the [LICENSE](../LICENSE) file for more information.
