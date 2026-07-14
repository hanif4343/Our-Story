import 'package:equatable/equatable.dart';

/// Top-level metadata for the whole love story — the "Journey" in the
/// Journey → Chapter → Scene hierarchy. A single record for the whole
/// app (this is a personal anniversary gift, not a multi-story
/// platform), editable from Settings so the Creator isn't stuck with
/// the compiled-in defaults from `AppConstants` forever.
class Journey extends Equatable {
  final String title;
  final String tagline;
  final DateTime startDate;
  final DateTime anchorDate;
  final String description;

  /// The two names shown on the v1.3.0 Journey Intro's title card.
  /// Optional — the intro simply skips that card when either is empty.
  final String partnerOneName;
  final String partnerTwoName;

  /// Wedding date shown on the Journey Intro, distinct from [anchorDate]
  /// (which anniversary countdowns/labels elsewhere in the app use).
  /// Null hides the wedding-date card entirely.
  final DateTime? weddingDate;

  /// A third name credited on the Story ending's cinematic Credits
  /// sequence (v1.5.0) — e.g. a child's name, under "Featuring". Empty
  /// hides that credits line entirely.
  final String featuredName;

  const Journey({
    required this.title,
    required this.tagline,
    required this.startDate,
    required this.anchorDate,
    this.description = '',
    this.partnerOneName = '',
    this.partnerTwoName = '',
    this.weddingDate,
    this.featuredName = '',
  });

  Journey copyWith({
    String? title,
    String? tagline,
    DateTime? startDate,
    DateTime? anchorDate,
    String? description,
    String? partnerOneName,
    String? partnerTwoName,
    DateTime? weddingDate,
    bool clearWeddingDate = false,
    String? featuredName,
  }) {
    return Journey(
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      startDate: startDate ?? this.startDate,
      anchorDate: anchorDate ?? this.anchorDate,
      description: description ?? this.description,
      partnerOneName: partnerOneName ?? this.partnerOneName,
      partnerTwoName: partnerTwoName ?? this.partnerTwoName,
      weddingDate: clearWeddingDate ? null : (weddingDate ?? this.weddingDate),
      featuredName: featuredName ?? this.featuredName,
    );
  }

  @override
  List<Object?> get props => [
        title,
        tagline,
        startDate,
        anchorDate,
        description,
        partnerOneName,
        partnerTwoName,
        weddingDate,
        featuredName,
      ];
}
