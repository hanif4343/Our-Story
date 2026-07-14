import 'package:equatable/equatable.dart';

/// A first-class chapter in the Journey → Chapter → Scene hierarchy
/// (v1.2.0 Story Engine). Scenes link to a chapter via `Scene.chapterId`;
/// a scene without one still displays under its legacy free-text
/// `chapter` label (v1.1.0 behaviour) — linking to a real [Chapter] is
/// additive, not required, so nothing authored before v1.2.0 breaks.
class Chapter extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Chapter copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, order, createdAt, updatedAt];
}
