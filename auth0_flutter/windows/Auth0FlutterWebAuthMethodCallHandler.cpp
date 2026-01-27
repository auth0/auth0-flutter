/**
 * @file Auth0FlutterWebAuthMethodCallHandler.cpp
 * @brief Implementation of Auth0FlutterWebAuthMethodCallHandler
 */

#include "Auth0FlutterWebAuthMethodCallHandler.h"

namespace auth0_flutter
{

    /**
     * @brief Constructor - initializes the handler with a list of WebAuth handlers
     *
     * @param handlers Vector of WebAuthRequestHandler implementations
     *                 Each handler is responsible for a specific WebAuth operation
     */
    Auth0FlutterWebAuthMethodCallHandler::Auth0FlutterWebAuthMethodCallHandler(
        std::vector<std::unique_ptr<WebAuthRequestHandler>> handlers)
        : handlers_(std::move(handlers))
    {
    }

    /**
     * @brief Routes method calls to the appropriate handler
     *
     * This method implements the routing logic:
     * 1. Extract the method name from the method call
     * 2. Iterate through registered handlers to find a match
     * 3. If a handler matches, delegate to it
     * 4. If no handler matches, return NotImplemented
     *
     * The method also validates that arguments are provided as a map,
     * which is required by all WebAuth operations.
     *
     * @param method_call The method call from Flutter containing method name and arguments
     * @param result The result callback to return response to Flutter
     */
    void Auth0FlutterWebAuthMethodCallHandler::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        // Get the method name from the call
        const std::string &method = method_call.method_name();

        // All WebAuth methods require arguments to be a map
        const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (!args)
        {
            result->Error("bad_args", "Expected a map as arguments");
            return;
        }

        // Find and execute the matching handler
        for (const auto &handler : handlers_)
        {
            if (handler->method() == method)
            {
                handler->handle(args, std::move(result));
                return;
            }
        }

        // No handler found for this method
        result->NotImplemented();
    }

} // namespace auth0_flutter
