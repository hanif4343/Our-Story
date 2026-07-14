/// Build-time / environment level configuration flags.
class AppConfig {
  AppConfig._();

  /// This app is fully offline by design — no Firebase, no network calls.
  /// Kept as an explicit flag so any future contributor sees the constraint
  /// instead of accidentally wiring in a remote service.
  static const bool isOfflineOnly = true;

  static const String version = '1.5.0';
  static const String buildLabel = 'v1.5.0 Premium Romantic Experience';
}
