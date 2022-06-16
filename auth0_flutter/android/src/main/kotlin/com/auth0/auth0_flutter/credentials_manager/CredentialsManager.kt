package com.auth0.auth0_flutter.credentials_manager

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.android.authentication.storage.Storage

object CredentialsManagerAccessor {
    private var instances: MutableMap<Any, CredentialsManager> = mutableMapOf();

    fun getOrCreateInstance(authenticationAPIClient: AuthenticationAPIClient, storage: Storage): CredentialsManager {
        var key = authenticationAPIClient.baseURL + "-" + authenticationAPIClient.clientId;
        var instance = this.instances.get(key);

        if (instance == null) {
            instance = CredentialsManager(authenticationAPIClient, storage);
            this.instances[key] = instance;
        }

        return instance;
    }
}
