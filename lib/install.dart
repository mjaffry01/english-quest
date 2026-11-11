// "Install the app" support. On the web this talks to the helper in
// web/index.html; on every other platform the button is simply hidden.
export 'install_stub.dart' if (dart.library.js_interop) 'install_web.dart';
