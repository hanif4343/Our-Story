import 'package:file_picker/file_picker.dart';
import 'media_storage_service.dart';

/// Lets the Creator pick a background-music audio file from device
/// storage. Distinct from [AudioRecorderService], which *captures* new
/// audio via the microphone rather than picking an existing file.
abstract class MusicPickerService {
  Future<String?> pickMusic();
}

class MusicPickerServiceImpl implements MusicPickerService {
  final MediaStorageService _storageService;
  MusicPickerServiceImpl({required MediaStorageService storageService}) : _storageService = storageService;

  @override
  Future<String?> pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return _storageService.persist(path, MediaCategory.audio);
  }
}
