/**
 * @file auth0_flutter_plugin.cpp
 * @brief Main plugin implementation for Auth0 Flutter Windows
 *
 * This file contains the main plugin class for Auth0 Flutter Windows.
 * The plugin follows a handler pattern similar to the Android and iOS implementations,
 * delegating method calls to specialized handlers.
 *
 * Architecture:
 * - Auth0FlutterPlugin: Main plugin class, registers with Flutter engine
 * - Auth0FlutterWebAuthMethodCallHandler: Routes method calls to appropriate handlers
 * - LoginWebAuthRequestHandler: Handles webAuth#login
 * - LogoutWebAuthRequestHandler: Handles webAuth#logout
 *
 * Helper utilities are now in separate files:
 * - oauth_helpers.h: PKCE functions, OAuth callback handling
 * - url_utils.h: URL encoding/decoding
 * - windows_utils.h: Windows-specific utilities
 */

#include "auth0_flutter_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

// Utility headers
#include "oauth_helpers.h"
#include "url_utils.h"
#include "windows_utils.h"

// WebAuth handlers
#include "Auth0FlutterWebAuthMethodCallHandler.h"
#include "request_handlers/web_auth/LoginWebAuthRequestHandler.h"
#include "request_handlers/web_auth/LogoutWebAuthRequestHandler.h"

namespace auth0_flutter
{

    /**
     * @brief Registers the plugin with the Flutter engine
     *
     * Sets up the WebAuth method channel and initializes the plugin with
     * all required handlers. This follows the same channel name and architecture
     * as Android and iOS implementations.
     *
     * Channel: "auth0.com/auth0_flutter/web_auth"
     * Methods supported:
     * - webAuth#login: Handled by LoginWebAuthRequestHandler
     * - webAuth#logout: Handled by LogoutWebAuthRequestHandler
     *
     * @param registrar The Flutter plugin registrar
     */
    void Auth0FlutterPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "auth0.com/auth0_flutter/web_auth",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<Auth0FlutterPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));
    }

    /**
     * @brief Constructor - initializes the plugin with WebAuth handlers
     *
     * Creates and registers all WebAuth request handlers following the
     * strategy pattern used in Android and iOS implementations.
     */
    Auth0FlutterPlugin::Auth0FlutterPlugin()
    {
        // Initialize WebAuth method call handler with all request handlers
        std::vector<std::unique_ptr<WebAuthRequestHandler>> handlers;
        handlers.push_back(std::make_unique<LoginWebAuthRequestHandler>());
        handlers.push_back(std::make_unique<LogoutWebAuthRequestHandler>());

        webAuthCallHandler_ = std::make_unique<Auth0FlutterWebAuthMethodCallHandler>(
            std::move(handlers));
    }

    Auth0FlutterPlugin::~Auth0FlutterPlugin() {}

    /**
     * @brief Handles method calls from Flutter
     *
     * Delegates all method calls to the appropriate handler. This implementation
     * follows the same pattern as Android and iOS, using a handler-based architecture
     * for clean separation of concerns.
     *
     * All WebAuth methods (login, logout) are handled by webAuthCallHandler_,
     * which routes to specialized handlers based on the method name.
     *
     * @param method_call The method call from Flutter
     * @param result Callback to return results to Flutter
     */
    void Auth0FlutterPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        // Delegate all method calls to the WebAuth handler
        // The handler will route to appropriate specialized handlers based on method name
        webAuthCallHandler_->HandleMethodCall(method_call, std::move(result));
    }

} // namespace auth0_flutter
