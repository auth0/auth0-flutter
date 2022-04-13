package com.auth0.auth0_flutter

import com.auth0.android.result.UserProfile
import java.text.SimpleDateFormat
import java.util.*

fun UserProfile.toMap(): Map<String, Any?> {
    val sdf =
        SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

    val formattedDate = if (this.createdAt != null) sdf.format(this.createdAt) else null;

    return mapOf(
        "nickname" to this.nickname,
        "createdAt" to formattedDate,
        "email" to this.email,
        "familyName" to this.familyName,
        "givenName" to this.givenName,
        "isEmailVerified" to this.isEmailVerified,
        "name" to this.name,
        "pictureURL" to this.pictureURL,
        "userMetadata" to this.getUserMetadata(),
        "appMetadata" to this.getAppMetadata(),
        "extraInfo" to this.getExtraInfo(),
    )
}
