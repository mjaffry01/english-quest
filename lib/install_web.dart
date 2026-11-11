import 'dart:js_interop';

@JS('eqInstallAvailable')
external JSBoolean _available();

@JS('eqInstallOpen')
external void _open();

/// True when the site is open in a browser (not yet running as the installed app).
bool canOfferInstall() {
  try {
    return _available().toDart;
  } catch (_) {
    return false;
  }
}

/// Shows the browser's install prompt, or step-by-step instructions for this phone.
void openInstall() {
  try {
    _open();
  } catch (_) {}
}
