package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.storage.CredentialsManagerException
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class CredentialsManagerExceptionExtensionsTest {

    @Test
    fun `should set isRetryable to false when cause is null`() {
        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(null)

        val map = exception.toMap()

        assertThat(map["_isRetryable"], equalTo(false))
    }

    @Test
    fun `should set isRetryable to true when cause is a network AuthenticationException`() {
        val authException = mock(AuthenticationException::class.java)
        `when`(authException.isNetworkError).thenReturn(true)

        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(authException)

        val map = exception.toMap()

        assertThat(map["_isRetryable"], equalTo(true))
    }

    @Test
    fun `should set isRetryable to false when cause is a non-network AuthenticationException`() {
        val authException = mock(AuthenticationException::class.java)
        `when`(authException.isNetworkError).thenReturn(false)

        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(authException)

        val map = exception.toMap()

        assertThat(map["_isRetryable"], equalTo(false))
    }

    @Test
    fun `should set isRetryable to false when cause is a generic exception`() {
        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(RuntimeException("generic error"))

        val map = exception.toMap()

        assertThat(map["_isRetryable"], equalTo(false))
    }

    @Test
    fun `should include cause in map when cause is present`() {
        val cause = RuntimeException("network error")
        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(cause)

        val map = exception.toMap()

        assertThat(map["cause"], equalTo(cause.toString()))
    }

    @Test
    fun `should include causeStackTrace in map when cause is present`() {
        val cause = RuntimeException("network error")
        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(cause)

        val map = exception.toMap()

        assertThat(map["causeStackTrace"], equalTo(cause.stackTraceToString()))
    }

    @Test
    fun `should not include cause or causeStackTrace in map when cause is null`() {
        val exception = mock(CredentialsManagerException::class.java)
        `when`(exception.cause).thenReturn(null)

        val map = exception.toMap()

        assertThat(map.containsKey("cause"), equalTo(false))
        assertThat(map.containsKey("causeStackTrace"), equalTo(false))
    }
}
