import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../../domain/entities/scene.dart';
import '../viewmodels/scene_editor_viewmodel.dart';
import '../widgets/animation_selector.dart';
import '../widgets/chapter_picker_field.dart';
import '../widgets/letter_editor_section.dart';
import '../widgets/media_picker_section.dart';
import '../widgets/milestone_selector.dart';
import '../widgets/music_selector.dart';
import '../widgets/tag_input_field.dart';
import '../widgets/transition_selector.dart';
import '../widgets/video_picker_section.dart';
import '../widgets/voice_recorder_widget.dart';
import '../widgets/year_chapter_fields.dart';
import 'scene_preview_screen.dart';

/// Create/Edit Scene screen. Every creative choice (story text, media,
/// animation, transition, background, music, voice, duration, tags,
/// favorite) is authored here, with a silent debounced auto-save
/// running alongside the explicit Save button.
class SceneEditorScreen extends ConsumerStatefulWidget {
  final Scene? scene;
  const SceneEditorScreen({super.key, required this.scene});

  @override
  ConsumerState<SceneEditorScreen> createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends ConsumerState<SceneEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _storyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.scene?.title ?? '');
    _subtitleController = TextEditingController(text: widget.scene?.subtitle ?? '');
    _storyController = TextEditingController(text: widget.scene?.storyText ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos(SceneEditorViewModel viewModel) async {
    try {
      final paths = await ref.read(imagePickerServiceProvider).pickMultiplePhotos();
      viewModel.addPhotoPaths(paths);
    } catch (e) {
      _showError('Could not add photos: $e');
    }
  }

  Future<void> _replacePhoto(SceneEditorViewModel viewModel, String oldPath) async {
    try {
      final newPath = await ref.read(imagePickerServiceProvider).pickSinglePhoto();
      if (newPath == null) return;
      viewModel.removePhotoPath(oldPath);
      viewModel.addPhotoPath(newPath);
    } catch (e) {
      _showError('Could not replace photo: $e');
    }
  }

  Future<void> _pickMusic(SceneEditorViewModel viewModel) async {
    try {
      final path = await ref.read(musicPickerServiceProvider).pickMusic();
      if (path != null) viewModel.setMusicPath(path);
    } catch (e) {
      _showError('Could not add music: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds a throwaway [Scene] from the *current, possibly-unsaved*
  /// editor state and pushes [ScenePreviewScreen] with it directly —
  /// v1.4.0: previewing no longer requires saving first.
  void _previewScene(SceneEditorState state) {
    final now = DateTime.now();
    final draft = Scene(
      id: state.id ?? 'draft-preview',
      order: 0,
      title: state.title.trim().isEmpty ? 'Untitled Scene' : state.title.trim(),
      subtitle: state.subtitle.trim(),
      date: state.date,
      year: state.year == 0 ? (state.date?.year ?? 0) : state.year,
      chapter: state.chapter.trim(),
      chapterId: state.chapterId,
      storyText: state.storyText.trim(),
      letter: state.letter,
      photoPaths: state.photoPaths,
      videoPaths: state.videoPaths,
      voiceRecordingPath: state.voiceRecordingPath,
      voiceNote: state.voiceNote,
      musicPath: state.musicPath,
      musicTrimStart: state.musicTrimStart,
      musicTrimEnd: state.musicTrimEnd,
      animationType: state.animationType,
      transitionType: state.transitionType,
      backgroundType: state.backgroundType,
      backgroundColorHex: state.backgroundColorHex,
      displayDuration: state.displayDuration,
      isFavorite: state.isFavorite,
      tags: state.tags,
      milestoneType: state.milestoneType,
      createdAt: now,
      updatedAt: now,
    );
    context.push(AppRoutes.scenePreview, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final provider = sceneEditorViewModelProvider(widget.scene);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      if (next.saveStatus == SceneEditorSaveStatus.saved) {
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(
        title: Text(state.isEditing ? 'Edit Scene' : 'New Scene'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Preview Scene',
            onPressed: () => _previewScene(state),
          ),
          IconButton(
            icon: Icon(
              state.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: state.isFavorite ? AppColors.rosePink : AppColors.mutedWhite,
            ),
            onPressed: viewModel.toggleFavorite,
          ),
          TextButton(
            onPressed: state.saveStatus == SceneEditorSaveStatus.saving ? null : viewModel.save,
            child: const Text('Save'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: _AutoSaveIndicator(status: state.saveStatus, lastAutoSavedAt: state.lastAutoSavedAt),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ValidationWarnings(state: state),
          AppTextField(
            controller: _titleController,
            label: 'Scene Title',
            hint: 'e.g. The Day We Met',
            onChanged: viewModel.setTitle,
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _subtitleController,
            label: 'Subtitle',
            hint: 'A short line beneath the title',
            onChanged: viewModel.setSubtitle,
          ),
          const SizedBox(height: 18),
          _DatePickerField(date: state.date, onPick: viewModel.setDate, onClear: viewModel.clearDate),
          const SizedBox(height: 18),
          YearChapterFields(
            year: state.year,
            chapter: state.chapter,
            onYearChanged: viewModel.setYear,
            onChapterChanged: viewModel.setChapter,
          ),
          const SizedBox(height: 18),
          ChapterPickerField(chapterId: state.chapterId, onChanged: viewModel.setChapterId),
          const SizedBox(height: 18),
          AppTextField(
            controller: _storyController,
            label: 'Story Text',
            hint: 'Write this chapter of your story…',
            maxLines: 6,
            onChanged: viewModel.setStoryText,
          ),
          const SizedBox(height: 24),
          LetterEditorSection(letter: state.letter, onChanged: viewModel.setLetter),
          const SizedBox(height: 24),
          MediaPickerSection(
            photoPaths: state.photoPaths,
            onAddPhoto: () => _pickPhotos(viewModel),
            onRemovePhoto: viewModel.removePhotoPath,
            onReplacePhoto: (oldPath) => _replacePhoto(viewModel, oldPath),
            onReorder: viewModel.reorderPhotoPaths,
          ),
          const SizedBox(height: 24),
          VideoPickerSection(
            videoPaths: state.videoPaths,
            onAdd: viewModel.addVideoPath,
            onRemove: viewModel.removeVideoPath,
            onReorder: viewModel.reorderVideoPaths,
          ),
          const SizedBox(height: 24),
          MusicSelector(
            selectedPath: state.musicPath,
            onPick: () => _pickMusic(viewModel),
            onClear: () => viewModel.setMusicPath(null),
            trimStart: state.musicTrimStart,
            trimEnd: state.musicTrimEnd,
            onTrimChanged: (start, end) => viewModel.setMusicTrim(start: start, end: end),
          ),
          const SizedBox(height: 24),
          VoiceRecorderWidget(
            recordingPath: state.voiceRecordingPath,
            onChanged: viewModel.setVoiceRecordingPath,
            voiceNote: state.voiceNote,
            onVoiceNoteChanged: viewModel.setVoiceNote,
          ),
          const SizedBox(height: 24),
          TagInputField(tags: state.tags, onAdd: viewModel.addTag, onRemove: viewModel.removeTag),
          const SizedBox(height: 24),
          MilestoneSelector(selected: state.milestoneType, onChanged: viewModel.setMilestoneType),
          const SizedBox(height: 24),
          AnimationSelector(selected: state.animationType, onChanged: viewModel.setAnimationType),
          const SizedBox(height: 24),
          TransitionSelector(selected: state.transitionType, onChanged: viewModel.setTransitionType),
          const SizedBox(height: 24),
          _DurationField(
            duration: state.displayDuration,
            hasVideo: state.videoPaths.isNotEmpty,
            onChanged: viewModel.setDisplayDuration,
          ),
          if (state.saveStatus == SceneEditorSaveStatus.error && state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(state.errorMessage!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 28),
          AppButton(
            label: state.isEditing ? 'Save Changes' : 'Create Scene',
            expand: true,
            isLoading: state.saveStatus == SceneEditorSaveStatus.saving,
            onPressed: viewModel.save,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AutoSaveIndicator extends StatelessWidget {
  final SceneEditorSaveStatus status;
  final DateTime? lastAutoSavedAt;
  const _AutoSaveIndicator({required this.status, required this.lastAutoSavedAt});

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    switch (status) {
      case SceneEditorSaveStatus.autoSaving:
        label = 'Saving…';
        icon = Icons.cloud_upload_outlined;
        break;
      case SceneEditorSaveStatus.autoSaved:
        label = lastAutoSavedAt != null ? 'Autosaved at ${_timeOfDay(lastAutoSavedAt!)}' : 'Autosaved';
        icon = Icons.cloud_done_outlined;
        break;
      default:
        label = 'Draft — changes save automatically';
        icon = Icons.edit_note_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: AppColors.mutedWhite),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  String _timeOfDay(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Friendly, non-blocking heads-up about a scene that's missing common
/// content — never prevents saving (only an empty title/story text does
/// that, in [SceneEditorViewModel.save]), just nudges the Creator.
class _ValidationWarnings extends StatelessWidget {
  final SceneEditorState state;
  const _ValidationWarnings({required this.state});

  @override
  Widget build(BuildContext context) {
    final warnings = <String>[];

    if (state.title.trim().isEmpty) {
      warnings.add('This scene has no title yet.');
    }
    final hasMedia = state.photoPaths.isNotEmpty || state.videoPaths.isNotEmpty;
    if (!hasMedia) {
      warnings.add('No photos or videos attached — this scene will show text only.');
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(warning, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;
  const _DatePickerField({required this.date, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: AppColors.surfaceBlue, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.gold, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDate ? DateFormatter.scene(date!) : 'No date set (optional)',
                style: AppTextStyles.bodyMedium.copyWith(color: hasDate ? Colors.white : AppColors.mutedWhite),
              ),
            ),
            if (hasDate)
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.mutedWhite),
                tooltip: 'Clear date',
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  final Duration duration;
  final bool hasVideo;
  final ValueChanged<Duration> onChanged;
  const _DurationField({required this.duration, required this.hasVideo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scene Duration in Story Mode', style: AppTextStyles.label),
        Slider(
          value: duration.inSeconds.toDouble().clamp(3, 20),
          min: 3,
          max: 20,
          divisions: 17,
          activeColor: AppColors.gold,
          label: '${duration.inSeconds}s',
          onChanged: (value) => onChanged(Duration(seconds: value.round())),
        ),
        if (hasVideo)
          Text(
            'This scene has a video, so it\'ll play for the video\'s full length in Story Mode instead — this setting only applies to photo/text scenes.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.mutedWhite),
          ),
      ],
    );
  }
}
