package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.io.Serializable
import java.lang.Exception


class GetIdTokenContentRequestHandler: CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getUserInfo"
    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
            result.success(
                mapOf(
                    "id" to credentialsManager.userProfile?.getId(),
                    "name" to credentialsManager.userProfile?.name,
                    "nickname" to credentialsManager.userProfile?.nickname,
                    "pictureURL" to credentialsManager.userProfile?.pictureURL,
                    "email" to credentialsManager.userProfile?.email,
                    "isEmailVerified" to credentialsManager.userProfile?.isEmailVerified,
                    "familyName" to credentialsManager.userProfile?.familyName,
                    "createdAt" to credentialsManager.userProfile?.createdAt,
                    "identities" to credentialsManager.userProfile?.getIdentities()?.map {
                        mapOf(
                            "provider" to it.provider,
                            "id" to it.connection,
                            "isSocial" to it.isSocial,
                            "accessToken" to it.accessToken,
                            "accessTokenSecret" to it.accessTokenSecret,
                            "profileInfo" to it.getProfileInfo()
                        )
                    },
                    "extraInfo" to credentialsManager.userProfile?.getExtraInfo(),
                    "userMetadata" to credentialsManager.userProfile?.getUserMetadata(),
                    "appMetadata" to credentialsManager.userProfile?.getAppMetadata(),
                    "givenName" to credentialsManager.userProfile?.givenName
                )
            )
    }
}
