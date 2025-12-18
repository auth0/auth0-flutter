//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auth0_flutter/auth0_flutter_plugin_c_api.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) auth0_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "Auth0FlutterPluginCApi");
  auth0_flutter_plugin_c_api_register_with_registrar(auth0_flutter_registrar);
}
