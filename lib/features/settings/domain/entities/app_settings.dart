import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool hasCreatorPassword;
  final bool hasCompletedFirstSetup;
  final String? defaultMusicPath;
  final bool autoPlayMusicInStoryMode;

  /// Story Mode background-music volume, 0.0–1.0 (v1.4.0 Music Manager).
  final double backgroundMusicVolume;

  const AppSettings({
    required this.hasCreatorPassword,
    required this.hasCompletedFirstSetup,
    this.defaultMusicPath,
    required this.autoPlayMusicInStoryMode,
    this.backgroundMusicVolume = 0.55,
  });

  factory AppSettings.initial() => const AppSettings(
        hasCreatorPassword: false,
        hasCompletedFirstSetup: false,
        autoPlayMusicInStoryMode: true,
      );

  @override
  List<Object?> get props => [
        hasCreatorPassword,
        hasCompletedFirstSetup,
        defaultMusicPath,
        autoPlayMusicInStoryMode,
        backgroundMusicVolume,
      ];
}
