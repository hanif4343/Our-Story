import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Shared dialog for both "Create Chapter" and "Rename Chapter" — the
/// only difference is the initial values and the confirm label.
class ChapterEditorDialog extends StatefulWidget {
  final String initialTitle;
  final String initialSubtitle;
  final String confirmLabel;

  const ChapterEditorDialog({
    super.key,
    this.initialTitle = '',
    this.initialSubtitle = '',
    this.confirmLabel = 'Create',
  });

  static Future<({String title, String subtitle})?> show(
    BuildContext context, {
    String initialTitle = '',
    String initialSubtitle = '',
    String confirmLabel = 'Create',
  }) {
    return showDialog<({String title, String subtitle})>(
      context: context,
      builder: (_) => ChapterEditorDialog(
        initialTitle: initialTitle,
        initialSubtitle: initialSubtitle,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<ChapterEditorDialog> createState() => _ChapterEditorDialogState();
}

class _ChapterEditorDialogState extends State<ChapterEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _subtitleController = TextEditingController(text: widget.initialSubtitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.confirmLabel == 'Create' ? 'New Chapter' : 'Rename Chapter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Chapter Title',
              hint: 'e.g. Chapter 1: How We Met',
              validator: (v) => Validators.requiredField(v, label: 'Chapter title'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _subtitleController,
              label: 'Subtitle (optional)',
              hint: 'A short description of this chapter',
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: widget.confirmLabel,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop((title: _titleController.text.trim(), subtitle: _subtitleController.text.trim()));
          },
        ),
      ],
    );
  }
}
