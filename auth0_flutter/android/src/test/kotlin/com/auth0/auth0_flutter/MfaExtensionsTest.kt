package com.auth0.auth0_flutter

import com.auth0.android.authentication.mfa.MfaException.MfaEnrollmentException
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
