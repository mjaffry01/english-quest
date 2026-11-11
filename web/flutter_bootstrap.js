{{flutter_js}}
{{flutter_build_config}}

// Start Flutter without its built-in service worker. Flutter's default worker
// is a deprecated stub that unregisters itself, which would also remove our
// offline worker (sw.js) because both share the same scope.
_flutter.loader.load();
