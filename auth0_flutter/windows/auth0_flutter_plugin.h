#ifndef FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace auth0_flutter
{

    class Auth0FlutterPlugin : public flutter::Plugin
    {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        Auth0FlutterPlugin();

        virtual ~Auth0FlutterPlugin();

        // Disallow copy and assign.
        Auth0FlutterPlugin(const Auth0FlutterPlugin &) = delete;
        Auth0FlutterPlugin &operator=(const Auth0FlutterPlugin &) = delete;

        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
