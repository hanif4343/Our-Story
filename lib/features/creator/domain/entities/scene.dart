import 'package:equatable/equatable.dart';
import 'transition_type.dart';
import 'background_type.dart';
import 'letter.dart';
import 'scene_milestone_type.dart';
import '../../../animation/domain/animation_type.dart';
import '../../../media/domain/entities/media_model.dart';
import '../../../media/domain/entities/voice_note.dart';

/// Pure domain entity — no Hive, no JSON, no framework concerns.
/// This is what ViewModels and use cases operate on.
class Scene extends Equatable {
  final String id;
  final int order;
  final String title;

  /// Short line shown beneath the title (e.g. "The day everything changed").
  final String subtitle;

  /// Optional — a scene doesn't have to be pinned to a real calendar
  /// date. `null` means "no date set" and is a perfectly valid state.
  final DateTime? date;

  /// The story's own narrative year for this scene (usually `date.year`,
  /// but kept independent so a Creator can group scenes thematically even
  /// if the literal date is uncertain or symbolic).
  final int year;

  /// Free-text chapter label used to group scenes (e.g. "Chapter 1: How We Met").
  /// Kept for full v1.1.0 backward compatibility — a scene's chapter
  /// grouping falls back to this string when [chapterId] is unset. See
  /// `features/timeline/domain/services/timeline_service.dart`.
  final String chapter;

  /// Links this scene to a real, persisted [Chapter] record (v1.2.0
  /// Story Engine). Null for any scene authored before v1.2.0, or for
  /// scenes that only use the legacy free-text [chapter] label.
  final String? chapterId;

  final String storyText;

  /// The richer "letter reveal" content for this scene (v1.2.0). Null
  /// means the scene renders its plain [title]/[subtitle]/[storyText]
  /// as it always has.
  final Letter? letter;

  /// Local file-system paths (never bytes) — see features/media.
  final List<String> photoPaths;
  final List<String> videoPaths;
  final String? voiceRecordingPath;

  /// Richer successor to [voiceRecordingPath] carrying duration + a
  /// waveform (v1.2.0). Null means this scene either has no voice note,
  /// or one recorded before v1.2.0 that only has the plain path.
  final VoiceNote? voiceNote;

  final String? musicPath;

  /// Non-destructive trim range for [musicPath] (v1.6.0 Audio Trim
  /// Editor) — the source file is never modified, only playback (both
  /// the Creator's preview and Story Mode's background music) is
  /// clipped to `[musicTrimStart, musicTrimEnd]`. `musicTrimEnd` of
  /// `null` means "play through to the track's natural end".
  final Duration musicTrimStart;
  final Duration? musicTrimEnd;

  final AnimationType animationType;
  final TransitionType transitionType;
  final BackgroundType backgroundType;

  /// Hex string (e.g. `#0B1026`) used when [backgroundType] is [BackgroundType.solidColor].
  final String? backgroundColorHex;

  /// How long this scene stays on screen during autoplay in Story Mode.
  final Duration displayDuration;

  /// Whether the Creator has marked this scene as a favorite/highlight.
  final bool isFavorite;

  /// Free-form labels for search & organization (e.g. "proposal", "trip").
  final List<String> tags;

  /// Themed decorative treatment for this scene (v1.3.0 Cinematic
  /// Experience Engine) — see [SceneMilestoneType]. Defaults to `none`,
  /// which changes nothing about how the scene renders.
  final SceneMilestoneType milestoneType;

  final DateTime createdAt;
  final DateTime updatedAt;

  Scene({
    required this.id,
    required this.order,
    required this.title,
    this.subtitle = '',
    this.date,
    int? year,
    this.chapter = '',
    this.chapterId,
    required this.storyText,
    this.letter,
    this.photoPaths = const [],
    this.videoPaths = const [],
    this.voiceRecordingPath,
    this.voiceNote,
    this.musicPath,
    this.musicTrimStart = Duration.zero,
    this.musicTrimEnd,
    this.animationType = AnimationType.none,
    this.transitionType = TransitionType.fade,
    this.backgroundType = BackgroundType.romanticGradient,
    this.backgroundColorHex,
    this.displayDuration = const Duration(seconds: 8),
    this.isFavorite = false,
    this.tags = const [],
    this.milestoneType = SceneMilestoneType.none,
    required this.createdAt,
    required this.updatedAt,
  }) : year = year ?? (date?.year ?? 0);

  Scene copyWith({
    String? id,
    int? order,
    String? title,
    String? subtitle,
    DateTime? date,
    bool clearDate = false,
    int? year,
    String? chapter,
    String? chapterId,
    String? storyText,
    Letter? letter,
    List<String>? photoPaths,
    List<String>? videoPaths,
    String? voiceRecordingPath,
    VoiceNote? voiceNote,
    String? musicPath,
    Duration? musicTrimStart,
    Duration? musicTrimEnd,
    bool clearMusicTrimEnd = false,
    AnimationType? animationType,
    TransitionType? transitionType,
    BackgroundType? backgroundType,
    String? backgroundColorHex,
    Duration? displayDuration,
    bool? isFavorite,
    List<String>? tags,
    SceneMilestoneType? milestoneType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Scene(
      id: id ?? this.id,
      order: order ?? this.order,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: clearDate ? null : (date ?? this.date),
      year: year ?? this.year,
      chapter: chapter ?? this.chapter,
      chapterId: chapterId ?? this.chapterId,
      storyText: storyText ?? this.storyText,
      letter: letter ?? this.letter,
      photoPaths: photoPaths ?? this.photoPaths,
      videoPaths: videoPaths ?? this.videoPaths,
      voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
      voiceNote: voiceNote ?? this.voiceNote,
      musicPath: musicPath ?? this.musicPath,
      musicTrimStart: musicTrimStart ?? this.musicTrimStart,
      musicTrimEnd: clearMusicTrimEnd ? null : (musicTrimEnd ?? this.musicTrimEnd),
      animationType: animationType ?? this.animationType,
      transitionType: transitionType ?? this.transitionType,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      displayDuration: displayDuration ?? this.displayDuration,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      milestoneType: milestoneType ?? this.milestoneType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ordered, typed view over [photoPaths] + [videoPaths] combined —
  /// photos first (in their existing order), then videos. Computed on
  /// each access; see [MediaModel] for why this isn't persisted.
  List<MediaModel> get mediaItems {
    final items = <MediaModel>[];
    for (var i = 0; i < photoPaths.length; i++) {
      items.add(MediaModel(id: '$id-photo-$i', type: MediaModelType.photo, path: photoPaths[i], order: i));
    }
    for (var i = 0; i < videoPaths.length; i++) {
      items.add(MediaModel(
        id: '$id-video-$i',
        type: MediaModelType.video,
        path: videoPaths[i],
        order: photoPaths.length + i,
      ));
    }
    return items;
  }

  @override
  List<Object?> get props => [
        id,
        order,
        title,
        subtitle,
        date,
        year,
        chapter,
        chapterId,
        storyText,
        letter,
        photoPaths,
        videoPaths,
        voiceRecordingPath,
        voiceNote,
        musicPath,
        musicTrimStart,
        musicTrimEnd,
        animationType,
        transitionType,
        backgroundType,
        backgroundColorHex,
        displayDuration,
        isFavorite,
        tags,
        milestoneType,
        createdAt,
        updatedAt,
      ];
}
