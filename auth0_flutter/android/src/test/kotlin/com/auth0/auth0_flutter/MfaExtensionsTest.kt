package com.auth0.auth0_flutter

import com.auth0.android.authentication.mfa.MfaException.MfaEnrollmentException
import com.auth0.android.result.TotpEnrollmentChallenge
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MfaExtensionsTest {

    @Test
    fun `toMfaEnrollmentMap maps TOTP associate response secret and recovery codes`() {
        // The ROPG `/mfa/associate` response returns the manual-entry key as
        // `secret` (not `manualInputCode`) plus `recoveryCodes`.
        val challenge = TotpEnrollmentChallenge(
            barcodeUri = "otpauth://totp/Example",
            secret = "SECRET-KEY",
            recoveryCodes = listOf("code-1", "code-2")
        )

        val map = challenge.toMfaEnrollmentMap()

        assertThat(map["authenticator_type"], equalTo("otp"))
        assertThat(map["totp_secret"], equalTo("SECRET-KEY"))
        assertThat(map["barcode_uri"], equalTo("otpauth://totp/Example"))
        assertThat(map["recovery_codes"], equalTo(listOf("code-1", "code-2")))
    }

    @Test
    fun `toMfaEnrollmentMap falls back to manualInputCode for totp_secret`() {

        val challenge = TotpEnrollmentChallenge(
            barcodeUri = "otpauth://totp/Example",
            manualInputCode = "MANUAL-KEY"
        )

        val map = challenge.toMfaEnrollmentMap()

        assertThat(map["totp_secret"], equalTo("MANUAL-KEY"))
    }

    @Test
    fun `toMfaMap sets isNetworkError true when code is network_error`() {
        val exception = mock<MfaEnrollmentException>()
        whenever(exception.getCode()).thenReturn("network_error")
        whenever(exception.getDescription()).thenReturn("Network error")
        whenever(exception.statusCode).thenReturn(0)

        val map = exception.toMfaMap()
        val errorFlags = map["_errorFlags"] as Map<*, *>

        assertThat(errorFlags["isNetworkError"], equalTo(true))
    }

    @Test
    fun `toMfaMap sets isNetworkError false for non-network codes`() {
        val exception = mock<MfaEnrollmentException>()
        whenever(exception.getCode()).thenReturn("invalid_request")
        whenever(exception.getDescription()).thenReturn("Invalid request")
        whenever(exception.statusCode).thenReturn(400)

        val map = exception.toMfaMap()
        val errorFlags = map["_errorFlags"] as Map<*, *>

        assertThat(errorFlags["isNetworkError"], equalTo(false))
        assertThat(map["_statusCode"], equalTo(400))
    }

    @Test
    fun `toMfaMap carries the native error code and description`() {
        val exception = mock<MfaEnrollmentException>()
        whenever(exception.getCode()).thenReturn("invalid_request")
        whenever(exception.getDescription()).thenReturn("Invalid request")
        whenever(exception.statusCode).thenReturn(400)

        val map = exception.toMfaMap()

        assertThat(map["code"], equalTo("invalid_request"))
        assertThat(map["description"], equalTo("Invalid request"))
    }
}
