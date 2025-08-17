#include "include/auth0_flutter/auth0_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "auth0_flutter_plugin.h"

void Auth0FlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auth0_flutter::Auth0FlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
