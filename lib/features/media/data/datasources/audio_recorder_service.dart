import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../../core/utils/id_generator.dart';
import 'media_storage_service.dart';

/// Captures Creator voice-over narration per scene using the device
/// microphone. Recordings are written to a temp file while active, then
/// copied into permanent app storage via [MediaStorageService] once
/// stopped.
abstract class AudioRecorderService {
  Future<void> startRecording();
  Future<String?> stopRecording();
  Future<bool> hasPermission();
  Future<bool> isRecording();
  Future<void> cancelRecording();

  /// Normalized (0.0–1.0) amplitude readings sampled at [interval] while
  /// recording is active — used to build a [VoiceNote.waveform] live,
  /// rather than re-analyzing the audio file after the fact. Only
  /// meaningful between [startRecording] and [stopRecording]/[cancelRecording].
  Stream<double> amplitudeStream({Duration interval});
}

class AudioRecorderServiceImpl implements AudioRecorderService {
  final AudioRecorder _recorder;
  final MediaStorageService _storageService;

  AudioRecorderServiceImpl({
    AudioRecorder? recorder,
    required MediaStorageService storageService,
  })  : _recorder = recorder ?? AudioRecorder(),
        _storageService = storageService;

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  @override
  Future<void> startRecording() async {
    final granted = await hasPermission();
    if (!granted) {
      throw StateError('Microphone permission was not granted.');
    }

    final tempDir = await getTemporaryDirectory();
    final path = p.join(tempDir.path, '${IdGenerator.generate()}.m4a');

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: path,
    );
  }

  @override
  Future<String?> stopRecording() async {
    final recordedPath = await _recorder.stop();
    if (recordedPath == null) return null;
    return _storageService.persist(recordedPath, MediaCategory.voice);
  }

  @override
  Future<bool> isRecording() => _recorder.isRecording();

  @override
  Future<void> cancelRecording() => _recorder.cancel();

  @override
  Stream<double> amplitudeStream({Duration interval = const Duration(milliseconds: 150)}) {
    // `record` reports amplitude in dBFS (roughly -45..0, quieter to
    // louder, device-dependent). Normalize to a friendly 0.0-1.0 range
    // for waveform bars — silence floors at 0, typical speech lands
    // comfortably in the 0.3-0.9 band.
    const noiseFloorDb = -45.0;
    return _recorder.onAmplitudeChanged(interval).map((amplitude) {
      final db = amplitude.current;
      final normalized = ((db - noiseFloorDb) / (0 - noiseFloorDb)).clamp(0.0, 1.0);
      return normalized;
    });
  }
}
