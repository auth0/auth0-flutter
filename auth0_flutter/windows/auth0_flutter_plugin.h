/**
 * @file auth0_flutter_plugin.h
 * @brief Main plugin header for Auth0 Flutter Windows
 *
 * Defines the Auth0FlutterPlugin class which serves as the entry point
 * for the Flutter plugin on Windows. This plugin handles WebAuth operations
 * by delegating to specialized handler classes.
 */

#ifndef FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace auth0_flutter
{
    // Forward declaration
    class Auth0FlutterWebAuthMethodCallHandler;

    /**
     * @class Auth0FlutterPlugin
     * @brief Main plugin class for Auth0 Flutter on Windows
     *
     * This class follows the same architectural pattern as Android and iOS:
     * - Registers with Flutter engine
     * - Creates method channel for WebAuth operations
     * - Delegates method calls to specialized handlers
     *
     * The plugin uses a handler-based architecture where each WebAuth operation
     * (login, logout) is implemented by a separate handler class, making the
     * code modular, testable, and consistent with other platforms.
     */
    class Auth0FlutterPlugin : public flutter::Plugin
    {
    public:
        /**
         * @brief Registers the plugin with the Flutter Windows engine
         * @param registrar The plugin registrar provided by Flutter
         */
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        /**
         * @brief Constructor - initializes WebAuth handlers
         */
        Auth0FlutterPlugin();

        /**
         * @brief Destructor
         */
        virtual ~Auth0FlutterPlugin();

        // Disallow copy and assign.
        Auth0FlutterPlugin(const Auth0FlutterPlugin &) = delete;
        Auth0FlutterPlugin &operator=(const Auth0FlutterPlugin &) = delete;

        /**
         * @brief Handles method calls from Flutter
         *
         * Routes method calls to the appropriate handler. All WebAuth methods
         * are handled by webAuthCallHandler_.
         *
         * @param method_call The method call from Flutter
         * @param result Callback to return results to Flutter
         */
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    private:
        /**
         * @brief Handler for all WebAuth method calls
         *
         * This handler manages login, logout, and other WebAuth operations
         * by routing to appropriate specialized handlers.
         */
        std::unique_ptr<Auth0FlutterWebAuthMethodCallHandler> webAuthCallHandler_;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
