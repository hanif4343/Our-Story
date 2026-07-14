import 'package:equatable/equatable.dart';

/// The romantic "letter reveal" content a scene can optionally carry —
/// richer than the scene's plain `storyText`: a distinct title/subtitle
/// for the reveal itself, a full letter body, an optional highlighted
/// quote, specific words to render highlighted within the body, and
/// toggles for the envelope-opening and typewriter-style reveal
/// animations.
///
/// Entirely optional per scene — when a scene has no [Letter], Story
/// Mode and Scene Preview simply render the scene's existing
/// title/subtitle/storyText as before (v1.1.0 behaviour, unchanged).
class Letter extends Equatable {
  /// Overrides the scene's title specifically for the letter reveal.
  /// Falls back to the scene's own title when null.
  final String? title;

  /// Overrides the scene's subtitle specifically for the letter reveal.
  final String? subtitle;

  /// The full letter body. Falls back to the scene's `storyText` when
  /// empty, so authoring a scene never requires writing the same prose
  /// twice.
  final String longLetter;

  /// A short standout line rendered separately (e.g. in italic gold),
  /// such as a favorite quote from that day.
  final String? quote;

  /// Words or short phrases that should render highlighted (gold,
  /// semi-bold) wherever they appear inside [longLetter].
  final List<String> highlightedWords;

  final bool typingAnimationEnabled;
  final bool envelopeAnimationEnabled;

  const Letter({
    this.title,
    this.subtitle,
    this.longLetter = '',
    this.quote,
    this.highlightedWords = const [],
    this.typingAnimationEnabled = true,
    this.envelopeAnimationEnabled = true,
  });

  Letter copyWith({
    String? title,
    String? subtitle,
    String? longLetter,
    String? quote,
    List<String>? highlightedWords,
    bool? typingAnimationEnabled,
    bool? envelopeAnimationEnabled,
  }) {
    return Letter(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      longLetter: longLetter ?? this.longLetter,
      quote: quote ?? this.quote,
      highlightedWords: highlightedWords ?? this.highlightedWords,
      typingAnimationEnabled: typingAnimationEnabled ?? this.typingAnimationEnabled,
      envelopeAnimationEnabled: envelopeAnimationEnabled ?? this.envelopeAnimationEnabled,
    );
  }

  @override
  List<Object?> get props =>
      [title, subtitle, longLetter, quote, highlightedWords, typingAnimationEnabled, envelopeAnimationEnabled];
}
