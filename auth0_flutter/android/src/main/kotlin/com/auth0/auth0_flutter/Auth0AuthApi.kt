package com.auth0.auth0_flutter

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient

object Auth0AuthApi {
    private var instances: MutableMap<Any, AuthenticationAPIClient> = mutableMapOf();

    fun getOrCreateInstance(auth0: Auth0): AuthenticationAPIClient {
        var key = auth0.getDomainUrl() + "-" + auth0.clientId;
        var instance = this.instances.get(key);

        if (instance == null) {
            instance = AuthenticationAPIClient(auth0);
            this.instances[key] = instance;
        }

        return instance;
    }
}
