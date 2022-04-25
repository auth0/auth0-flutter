package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AuthenticationExceptionExtensionsTest {

    @Test
    fun `should set errorFlags to false by default when calling toMap()`() {
        val exception = AuthenticationException(code = "Some Code", description = "Some Error")

        val map = exception.toMap();
        val errorFlags = map["_errorFlags"] as Map<String, Boolean>;

        assertThat(errorFlags["isMultifactorRequired"], equalTo(false));
        assertThat(errorFlags["isMultifactorEnrollRequired"], equalTo(false));
        assertThat(errorFlags["isMultifactorCodeInvalid"], equalTo(false));
        assertThat(errorFlags["isMultifactorTokenInvalid"], equalTo(false));
        assertThat(errorFlags["isPasswordNotStrongEnough"], equalTo(false));
        assertThat(errorFlags["isPasswordAlreadyUsed"], equalTo(false));
        assertThat(errorFlags["isRuleError"], equalTo(false));
        assertThat(errorFlags["isInvalidCredentials"], equalTo(false));
        assertThat(errorFlags["isRefreshTokenDeleted"], equalTo(false));
        assertThat(errorFlags["isAccessDenied"], equalTo(false));
        assertThat(errorFlags["isTooManyAttempts"], equalTo(false));
        assertThat(errorFlags["isVerificationRequired"], equalTo(false));
        assertThat(errorFlags["isNetworkError"], equalTo(false));
        assertThat(errorFlags["isBrowserAppNotAvailable"], equalTo(false));
        assertThat(errorFlags["isPKCENotAvailable"], equalTo(false));
        assertThat(errorFlags["isInvalidAuthorizeURL"], equalTo(false));
        assertThat(errorFlags["isInvalidConfiguration"], equalTo(false));
        assertThat(errorFlags["isCanceled"], equalTo(false));
        assertThat(errorFlags["isPasswordLeaked"], equalTo(false));
        assertThat(errorFlags["isLoginRequired"], equalTo(false));
    }

    @Test
    fun `should set errorFlags to true when calling toMap()`() {
        val testCases = mapOf(
            "isMultifactorRequired" to { exception: AuthenticationException ->
                `when`(exception.isMultifactorRequired).thenReturn(
                    true
                );
            },
            "isMultifactorEnrollRequired" to { exception: AuthenticationException ->
                `when`(exception.isMultifactorEnrollRequired).thenReturn(
                    true
                );
            },
            "isMultifactorCodeInvalid" to { exception: AuthenticationException ->
                `when`(exception.isMultifactorCodeInvalid).thenReturn(
                    true
                );
            },
            "isMultifactorTokenInvalid" to { exception: AuthenticationException ->
                `when`(exception.isMultifactorTokenInvalid).thenReturn(
                    true
                );
            },
            "isPasswordNotStrongEnough" to { exception: AuthenticationException ->
                `when`(exception.isPasswordNotStrongEnough).thenReturn(
                    true
                );
            },
            "isPasswordAlreadyUsed" to { exception: AuthenticationException ->
                `when`(exception.isPasswordAlreadyUsed).thenReturn(
                    true
                );
            },
            "isRuleError" to { exception: AuthenticationException ->
                `when`(exception.isRuleError).thenReturn(
                    true
                );
            },
            "isInvalidCredentials" to { exception: AuthenticationException ->
                `when`(exception.isInvalidCredentials).thenReturn(
                    true
                );
            },
            "isRefreshTokenDeleted" to { exception: AuthenticationException ->
                `when`(exception.isRefreshTokenDeleted).thenReturn(
                    true
                );
            },
            "isAccessDenied" to { exception: AuthenticationException ->
                `when`(exception.isAccessDenied).thenReturn(
                    true
                );
            },
            "isTooManyAttempts" to { exception: AuthenticationException ->
                doReturn("too_many_attempts").`when`(exception).getCode()
            },
            "isVerificationRequired" to { exception: AuthenticationException ->
                `when`(exception.isVerificationRequired).thenReturn(
                    true
                );
            },
            "isNetworkError" to { exception: AuthenticationException ->
                `when`(exception.isNetworkError).thenReturn(
                    true
                );
            },
            "isBrowserAppNotAvailable" to { exception: AuthenticationException ->
                `when`(exception.isBrowserAppNotAvailable).thenReturn(
                    true
                );
            },
            "isPKCENotAvailable" to { exception: AuthenticationException ->
                `when`(exception.isPKCENotAvailable).thenReturn(
                    true
                );
            },
            "isInvalidAuthorizeURL" to { exception: AuthenticationException ->
                `when`(exception.isInvalidAuthorizeURL).thenReturn(
                    true
                );
            },
            "isInvalidConfiguration" to { exception: AuthenticationException ->
                `when`(exception.isInvalidConfiguration).thenReturn(
                    true
                );
            },
            "isCanceled" to { exception: AuthenticationException ->
                `when`(exception.isCanceled).thenReturn(
                    true
                );
            },
            "isPasswordLeaked" to { exception: AuthenticationException ->
                `when`(exception.isPasswordLeaked).thenReturn(
                    true
                );
            },
            "isLoginRequired" to { exception: AuthenticationException ->
                `when`(exception.isLoginRequired).thenReturn(
                    true
                );
            }
        )

        testCases.entries.forEach { testCase ->
            val exception =
                spy(AuthenticationException(code = "Some Code", description = "Some Error"))

            val setupProperty = testCase.value;
            setupProperty(exception);

            val map = exception.toMap();
            val errorFlags = map["_errorFlags"] as Map<String, Boolean>;

            assertThat(
                "should set '" + testCase.key + "' to true when calling toMap()",
                errorFlags[testCase.key],
                equalTo(true)
            );

            val allOtherErrorFlags = errorFlags.entries.filter { it.key !== testCase.key };
            allOtherErrorFlags.forEach {
                assertThat(it.value, equalTo(false));
            }
        }
    }

    @Test
    fun `should set isTooManyAttempts to true when 'code' is 'too_many_attempts'`() {
        val exception =
            AuthenticationException(code = "too_many_attempts", description = "Some Error")

        assertThat(exception.isTooManyAttempts, equalTo(true));
    }

    @Test
    fun `should set statusCode when calling toMap()`() {
        val exception = AuthenticationException(mapOf(
            "code" to "Some Code", "description" to "Some Error"
        ), 50);

        val map = exception.toMap();
        val statusCode = map["_statusCode"] as Int;

        assertThat(statusCode, equalTo(50));
    }
}
