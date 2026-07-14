import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/journey.dart';

/// Edits the top-level Journey record — title, tagline, partner names,
/// wedding date, start date, anchor date, description. Defaults come
/// from `AppConstants` on first run (see `JourneyLocalDataSource`); this
/// dialog is how the Creator personalizes them without touching code.
class JourneyEditorDialog extends StatefulWidget {
  final Journey journey;

  const JourneyEditorDialog({super.key, required this.journey});

  static Future<Journey?> show(BuildContext context, Journey journey) {
    return showDialog<Journey>(
      context: context,
      builder: (_) => JourneyEditorDialog(journey: journey),
    );
  }

  @override
  State<JourneyEditorDialog> createState() => _JourneyEditorDialogState();
}

class _JourneyEditorDialogState extends State<JourneyEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _taglineController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _partnerOneController;
  late final TextEditingController _partnerTwoController;
  late final TextEditingController _featuredNameController;
  late DateTime _startDate;
  late DateTime _anchorDate;
  DateTime? _weddingDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journey.title);
    _taglineController = TextEditingController(text: widget.journey.tagline);
    _descriptionController = TextEditingController(text: widget.journey.description);
    _partnerOneController = TextEditingController(text: widget.journey.partnerOneName);
    _partnerTwoController = TextEditingController(text: widget.journey.partnerTwoName);
    _featuredNameController = TextEditingController(text: widget.journey.featuredName);
    _startDate = widget.journey.startDate;
    _anchorDate = widget.journey.anchorDate;
    _weddingDate = widget.journey.weddingDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _partnerOneController.dispose();
    _partnerTwoController.dispose();
    _featuredNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required _DateField field}) async {
    final initial = switch (field) {
      _DateField.start => _startDate,
      _DateField.anchor => _anchorDate,
      _DateField.wedding => _weddingDate ?? _startDate,
    };
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      switch (field) {
        case _DateField.start:
          _startDate = picked;
          break;
        case _DateField.anchor:
          _anchorDate = picked;
          break;
        case _DateField.wedding:
          _weddingDate = picked;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Journey'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Journey Title',
                validator: (v) => Validators.requiredField(v, label: 'Title'),
              ),
              const SizedBox(height: 14),
              AppTextField(controller: _taglineController, label: 'Tagline'),
              const SizedBox(height: 14),
              AppTextField(controller: _partnerOneController, label: 'Partner 1 Name'),
              const SizedBox(height: 14),
              AppTextField(controller: _partnerTwoController, label: 'Partner 2 Name'),
              const SizedBox(height: 14),
              AppTextField(
                controller: _featuredNameController,
                label: 'Featured Name (optional)',
                hint: 'Shown on the ending credits, e.g. a child\'s name',
              ),
              const SizedBox(height: 14),
              AppTextField(controller: _descriptionController, label: 'Description (optional)', maxLines: 3),
              const SizedBox(height: 14),
              _DateRow(label: 'Start Date', date: _startDate, onTap: () => _pickDate(field: _DateField.start)),
              const SizedBox(height: 10),
              _DateRow(label: 'Wedding Date', date: _weddingDate, onTap: () => _pickDate(field: _DateField.wedding)),
              const SizedBox(height: 10),
              _DateRow(label: 'Anchor Date', date: _anchorDate, onTap: () => _pickDate(field: _DateField.anchor)),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(label: 'Cancel', variant: AppButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        AppButton(
          label: 'Save',
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(widget.journey.copyWith(
              title: _titleController.text.trim(),
              tagline: _taglineController.text.trim(),
              description: _descriptionController.text.trim(),
              partnerOneName: _partnerOneController.text.trim(),
              partnerTwoName: _partnerTwoController.text.trim(),
              featuredName: _featuredNameController.text.trim(),
              startDate: _startDate,
              anchorDate: _anchorDate,
              weddingDate: _weddingDate,
              clearWeddingDate: _weddingDate == null,
            ));
          },
        ),
      ],
    );
  }
}

enum _DateField { start, anchor, wedding }

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateRow({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(date == null
                ? 'Not set'
                : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
}
