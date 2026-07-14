/// Centralised static asset paths used across the app.
class AssetPaths {
  AssetPaths._();

  static const String imagesRoot = 'assets/images';
  static const String audioRoot = 'assets/audio';

  static const String logo = '$imagesRoot/logo.png';
  static const String defaultBackground = '$imagesRoot/default_background.jpg';
  static const String placeholderPhoto = '$imagesRoot/placeholder_photo.png';

  static const String defaultAmbientMusic = '$audioRoot/ambient_theme.mp3';

  /// Soft paper-rustle effect for the envelope-open animation
  /// ([LetterView]). Ships without a bundled file — see that widget's
  /// doc comment; dropping a real file at this path activates it.
  static const String paperOpenSound = '$audioRoot/paper_open.mp3';

  /// Camera-shutter effect for the Wedding milestone's camera-flash beat.
  static const String cameraShutterSound = '$audioRoot/camera_shutter.mp3';
}
