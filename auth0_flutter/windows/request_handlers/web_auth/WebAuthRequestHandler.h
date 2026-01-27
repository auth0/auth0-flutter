/**
 * @file WebAuthRequestHandler.h
 * @brief Base interface for handling WebAuth method calls from Flutter
 *
 * This abstract base class defines the interface for WebAuth request handlers.
 * Concrete implementations handle specific WebAuth operations like login and logout.
 *
 * Pattern: Strategy pattern - allows different handlers for different WebAuth methods
 * while maintaining a consistent interface.
 */

#ifndef FLUTTER_PLUGIN_WEB_AUTH_REQUEST_HANDLER_H_
#define FLUTTER_PLUGIN_WEB_AUTH_REQUEST_HANDLER_H_

#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>
#include <memory>
#include <string>

namespace auth0_flutter
{

    /**
     * @class WebAuthRequestHandler
     * @brief Abstract base class for WebAuth method handlers
     *
     * Each concrete handler implements:
     * - method(): Returns the method name this handler responds to (e.g., "webAuth#login")
     * - handle(): Processes the method call and returns the result via the result callback
     */
    class WebAuthRequestHandler
    {
    public:
        virtual ~WebAuthRequestHandler() = default;

        /**
         * @brief Get the method name this handler responds to
         * @return The method name (e.g., "webAuth#login", "webAuth#logout")
         */
        virtual std::string method() const = 0;

        /**
         * @brief Handle the method call
         * @param arguments The arguments map from Flutter containing configuration
         * @param result The result callback to send the response back to Flutter
         *
         * The handler should:
         * 1. Validate and extract required arguments
         * 2. Perform the WebAuth operation (login, logout, etc.)
         * 3. Call result->Success() with the response data, or result->Error() on failure
         */
        virtual void handle(
            const flutter::EncodableMap *arguments,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) = 0;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_WEB_AUTH_REQUEST_HANDLER_H_
