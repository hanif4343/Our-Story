import 'package:uuid/uuid.dart';

/// Single source of truth for generating unique local IDs
/// (scenes, media items, timeline entries).
class IdGenerator {
  IdGenerator._();

  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
