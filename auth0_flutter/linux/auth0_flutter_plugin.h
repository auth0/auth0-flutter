#ifndef FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _Auth0FlutterPlugin Auth0FlutterPlugin;
typedef struct {
  GObjectClass parent_class;
} Auth0FlutterPluginClass;

FLUTTER_PLUGIN_EXPORT GType auth0_flutter_plugin_get_type();

#define AUTH0_FLUTTER_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), auth0_flutter_plugin_get_type(), \
                               Auth0FlutterPlugin))

FLUTTER_PLUGIN_EXPORT void auth0_flutter_plugin_c_api_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_AUTH0_FLUTTER_PLUGIN_H_
