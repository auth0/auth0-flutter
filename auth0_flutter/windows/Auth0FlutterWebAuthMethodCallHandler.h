/**
 * @file Auth0FlutterWebAuthMethodCallHandler.h
 * @brief Method call handler for WebAuth channel
 *
 * This class manages WebAuth method calls from Flutter by routing them to
 * appropriate specialized handlers based on the method name.
 *
 * Pattern: Chain of Responsibility / Strategy pattern
 * - Maintains a list of WebAuthRequestHandler implementations
 * - Routes incoming method calls to the handler that matches the method name
 * - Returns NotImplemented if no handler matches
 */

#ifndef FLUTTER_PLUGIN_AUTH0_FLUTTER_WEB_AUTH_METHOD_CALL_HANDLER_H_
#define FLUTTER_PLUGIN_AUTH0_FLUTTER_WEB_AUTH_METHOD_CALL_HANDLER_H_

#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>
#include <memory>
#include <vector>
#include "request_handlers/web_auth/WebAuthRequestHandler.h"

namespace auth0_flutter
{

    /**
     * @class Auth0FlutterWebAuthMethodCallHandler
     * @brief Routes WebAuth method calls to appropriate handlers
     *
     * This class implements the Strategy pattern for handling different WebAuth
     * operations. Each operation (login, logout) is implemented by a separate
     * handler class, making the code modular and testable.
     *
     * Usage:
     * 1. Create handler instance with list of WebAuthRequestHandlers
     * 2. Call HandleMethodCall() when a method is invoked from Flutter
     * 3. The handler will route to the appropriate WebAuthRequestHandler
     *
     * Example:
     * @code
     * auto handler = std::make_unique<Auth0FlutterWebAuthMethodCallHandler>(
     *     std::vector<std::unique_ptr<WebAuthRequestHandler>>{
     *         std::make_unique<LoginWebAuthRequestHandler>(),
     *         std::make_unique<LogoutWebAuthRequestHandler>()
     *     }
     * );
     * handler->HandleMethodCall(method_call, std::move(result));
     * @endcode
     */
    class Auth0FlutterWebAuthMethodCallHandler
    {
    public:
        /**
         * @brief Constructs the handler with a list of WebAuth request handlers
         * @param handlers Vector of WebAuthRequestHandler implementations
         */
        explicit Auth0FlutterWebAuthMethodCallHandler(
            std::vector<std::unique_ptr<WebAuthRequestHandler>> handlers);

        ~Auth0FlutterWebAuthMethodCallHandler() = default;

        // Disallow copy and assign
        Auth0FlutterWebAuthMethodCallHandler(const Auth0FlutterWebAuthMethodCallHandler &) = delete;
        Auth0FlutterWebAuthMethodCallHandler &operator=(const Auth0FlutterWebAuthMethodCallHandler &) = delete;

        /**
         * @brief Handles a method call from Flutter
         *
         * Routes the method call to the appropriate WebAuthRequestHandler based on
         * the method name. If no handler matches, returns NotImplemented.
         *
         * @param method_call The method call from Flutter
         * @param result The result callback to send response back to Flutter
         */
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    private:
        std::vector<std::unique_ptr<WebAuthRequestHandler>> handlers_;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_AUTH0_FLUTTER_WEB_AUTH_METHOD_CALL_HANDLER_H_
