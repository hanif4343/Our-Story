import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Chip-based tag editor: type a tag and press enter/done to add it,
/// tap the x on any chip to remove it. Used by the Scene Editor's
/// "Tags" field for free-form search/organization labels.
class TagInputField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const TagInputField({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onAdd(value);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: AppTextStyles.label),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'e.g. proposal, road trip…',
            suffixIcon: IconButton(icon: const Icon(Icons.add, color: AppColors.gold), onPressed: _submit),
          ),
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(color: AppColors.softWhite, fontSize: 12),
                      backgroundColor: AppColors.surfaceBlue,
                      deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.mutedWhite),
                      onDeleted: () => widget.onRemove(tag),
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
