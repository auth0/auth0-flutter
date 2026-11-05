package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.request.UpdateUserProfileRequest
import com.auth0.android.request.Request
import com.auth0.android.result.MyAccountProfile
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class UpdateUserProfileRequestHandlerTest {

    private fun handle(
        options: HashMap<String, Any>,
        configure: (Request<MyAccountProfile, MyAccountException>) -> Unit = {}
    ): Pair<MyAccountAPIClient, Result> {
        val handler = UpdateUserProfileRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<MyAccountProfile, MyAccountException>>()
        val request = MethodCallRequest(account = mock<Auth0>(), options)

        whenever(mockClient.updateUserProfile(any())).thenReturn(mockRequest)
        configure(mockRequest)

        handler.handle(mockClient, request, mockResult)
        return Pair(mockClient, mockResult)
    }

    @Test
    fun `should call updateUserProfile with every provided field`() {
        val (client, _) = handle(
            hashMapOf(
                "givenName" to "Jane",
                "familyName" to "Doe",
                "name" to "Jane Doe",
                "nickname" to "jane",
                "picture" to "https://example.com/jane.png"
            )
        )

        verify(client).updateUserProfile(
            eq(
                UpdateUserProfileRequest(
                    givenName = "Jane",
                    familyName = "Doe",
                    name = "Jane Doe",
                    nickname = "jane",
                    picture = "https://example.com/jane.png"
                )
            )
        )
    }

    @Test
    fun `should call updateUserProfile with an empty request when no field is provided`() {
        val (client, _) = handle(hashMapOf())

        verify(client).updateUserProfile(eq(UpdateUserProfileRequest()))
    }

    @Test
    fun `should call result success with the mapped profile`() {
        val (_, result) = handle(hashMapOf("nickname" to "jane")) { request ->
            doAnswer {
                it.getArgument<Callback<MyAccountProfile, MyAccountException>>(0)
                    .onSuccess(MyAccountProfile(nickname = "jane"))
            }.whenever(request).start(any())
        }

        val captor = argumentCaptor<Map<String, Any?>>()
        verify(result).success(captor.capture())
        assertThat(captor.firstValue["nickname"], equalTo("jane"))
    }

    @Test
    fun `should call result error on failure`() {
        val exception = mock<MyAccountException>()
        whenever(exception.getCode()).thenReturn("forbidden")
        whenever(exception.getDescription()).thenReturn("Forbidden")
        whenever(exception.statusCode).thenReturn(403)
        whenever(exception.isNetworkError).thenReturn(false)

        val (_, result) = handle(hashMapOf()) { request ->
            doAnswer {
                it.getArgument<Callback<MyAccountProfile, MyAccountException>>(0)
                    .onFailure(exception)
            }.whenever(request).start(any())
        }

        verify(result).error(eq("forbidden"), eq("Forbidden"), any())
    }
}
