@JS()
library slugify;

import 'package:js/js.dart';

// Calls invoke JavaScript `slugify(str)`.
@JS('slugify')
external String jsSlugify(String str);
