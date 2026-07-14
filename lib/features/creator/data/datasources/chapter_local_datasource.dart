import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chapter_model.dart';

/// Direct Hive access for chapters — mirrors
/// `SceneLocalDataSource`'s shape exactly.
abstract class ChapterLocalDataSource {
  List<ChapterModel> getAllChapters();
  ChapterModel? getChapterById(String id);
  Future<void> putChapter(ChapterModel chapter);
  Future<void> deleteChapter(String id);
  Future<void> reorderChapters(List<String> orderedIds);
}

class ChapterLocalDataSourceImpl implements ChapterLocalDataSource {
  final Box<ChapterModel> box;

  ChapterLocalDataSourceImpl(this.box);

  @override
  List<ChapterModel> getAllChapters() {
    try {
      final chapters = box.values.toList();
      chapters.sort((a, b) => a.order.compareTo(b.order));
      return chapters;
    } catch (e) {
      throw StorageException('Failed to read chapters: $e');
    }
  }

  @override
  ChapterModel? getChapterById(String id) {
    try {
      return box.values.cast<ChapterModel?>().firstWhere(
            (c) => c?.id == id,
            orElse: () => null,
          );
    } catch (e) {
      throw StorageException('Failed to read chapter $id: $e');
    }
  }

  @override
  Future<void> putChapter(ChapterModel chapter) async {
    try {
      await box.put(chapter.id, chapter);
    } catch (e) {
      throw StorageException('Failed to save chapter: $e');
    }
  }

  @override
  Future<void> deleteChapter(String id) async {
    try {
      final existing = getChapterById(id);
      if (existing == null) {
        throw NotFoundException('Chapter $id does not exist.');
      }
      await box.delete(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw StorageException('Failed to delete chapter: $e');
    }
  }

  @override
  Future<void> reorderChapters(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        final chapter = getChapterById(orderedIds[i]);
        if (chapter != null) {
          chapter.order = i;
          await chapter.save();
        }
      }
    } catch (e) {
      throw StorageException('Failed to reorder chapters: $e');
    }
  }
}
