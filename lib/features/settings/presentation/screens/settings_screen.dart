import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../creator/presentation/widgets/music_selector.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../../../timeline/presentation/viewmodels/journey_viewmodel.dart';
import '../../../timeline/presentation/widgets/journey_editor_dialog.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

/// Creator-only preferences: playback behaviour, password management,
/// Journey metadata, and build info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openChangePasswordDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  Future<void> _openJourneyEditor(BuildContext context, WidgetRef ref) async {
    final journey = ref.read(journeyViewModelProvider);
    if (journey == null) return;
    final updated = await JourneyEditorDialog.show(context, journey);
    if (updated != null) {
      await ref.read(journeyViewModelProvider.notifier).update(updated);
    }
  }

  Future<void> _pickGlobalMusic(BuildContext context, WidgetRef ref) async {
    try {
      final path = await ref.read(musicPickerServiceProvider).pickMusic();
      if (path != null) {
        await ref.read(settingsViewModelProvider.notifier).setDefaultMusicPath(path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add music: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final journey = ref.watch(journeyViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Journey', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_stories_outlined, color: AppColors.gold),
            title: Text(journey?.title ?? 'Loading…', style: const TextStyle(color: Colors.white)),
            subtitle: journey != null
                ? Text(
                    '${DateFormatter.short(journey.startDate)} — ${DateFormatter.short(journey.anchorDate)}',
                    style: const TextStyle(color: AppColors.mutedWhite, fontSize: 12),
                  )
                : null,
            trailing: const Icon(Icons.edit_outlined, color: AppColors.mutedWhite, size: 18),
            onTap: journey == null ? null : () => _openJourneyEditor(context, ref),
          ),
          const Divider(height: 40),
          const Text('Story Mode', style: AppTextStyles.label),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.autoPlayMusicInStoryMode,
            onChanged: viewModel.toggleAutoPlayMusic,
            activeThumbColor: AppColors.gold,
            title: const Text('Auto-play music', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Background music changes automatically between scenes.',
                style: TextStyle(color: AppColors.mutedWhite, fontSize: 12)),
          ),
          const Divider(height: 40),
          const Text('Music', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(
            'Set one global track to play whenever a scene has no music of its own.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          MusicSelector(
            selectedPath: settings.defaultMusicPath,
            onPick: () => _pickGlobalMusic(context, ref),
            onClear: () => viewModel.setDefaultMusicPath(null),
          ),
          const SizedBox(height: 18),
          Text('Volume', style: AppTextStyles.label),
          Slider(
            value: settings.backgroundMusicVolume.clamp(0.0, 1.0),
            activeColor: AppColors.gold,
            label: '${(settings.backgroundMusicVolume * 100).round()}%',
            onChanged: viewModel.setBackgroundMusicVolume,
          ),
          const Divider(height: 40),
          const Text('Creator Account', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_reset_outlined, color: AppColors.gold),
            title: const Text('Change Password', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Update the password protecting Creator Mode.',
                style: TextStyle(color: AppColors.mutedWhite, fontSize: 12)),
            onTap: () => _openChangePasswordDialog(context),
          ),
          const Divider(height: 40),
          const Text('About', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Version', style: TextStyle(color: Colors.white)),
            trailing: const Text(AppConfig.buildLabel, style: TextStyle(color: AppColors.mutedWhite)),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Storage', style: TextStyle(color: Colors.white)),
            trailing: Text('Fully local (Hive)', style: TextStyle(color: AppColors.mutedWhite)),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await ref.read(authViewModelProvider.notifier).changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = ref.read(authViewModelProvider).errorMessage ?? 'Could not update password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _currentController,
              label: 'Current Password',
              obscureText: true,
              validator: (v) => Validators.requiredField(v, label: 'Current password'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _newController,
              label: 'New Password',
              obscureText: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirmController,
              label: 'Confirm New Password',
              obscureText: true,
              validator: (v) => v != _newController.text ? 'Passwords do not match.' : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(label: 'Update', isLoading: _isSubmitting, onPressed: _submit),
      ],
    );
  }
}
