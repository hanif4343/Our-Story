import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/letter.dart';
import 'tag_input_field.dart';

/// Toggleable authoring section for a scene's [Letter] reveal. Collapsed
/// by default (a single switch) so scenes that don't want the richer
/// letter treatment stay visually simple — flipping it on reveals the
/// full letter-authoring form.
class LetterEditorSection extends StatefulWidget {
  final Letter? letter;
  final ValueChanged<Letter?> onChanged;

  const LetterEditorSection({super.key, required this.letter, required this.onChanged});

  @override
  State<LetterEditorSection> createState() => _LetterEditorSectionState();
}

class _LetterEditorSectionState extends State<LetterEditorSection> {
  late bool _enabled = widget.letter != null;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _quoteController;

  Letter get _current => widget.letter ?? const Letter();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _current.title ?? '');
    _subtitleController = TextEditingController(text: _current.subtitle ?? '');
    _bodyController = TextEditingController(text: _current.longLetter);
    _quoteController = TextEditingController(text: _current.quote ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _emit(Letter letter) => widget.onChanged(letter);

  void _toggleEnabled(bool value) {
    setState(() => _enabled = value);
    if (value) {
      _emit(_current);
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Letter Reveal', style: AppTextStyles.label),
            Switch(value: _enabled, activeColor: AppColors.gold, onChanged: _toggleEnabled),
          ],
        ),
        if (_enabled) ...[
          const SizedBox(height: 10),
          Text(
            'A romantic envelope-open reveal with typed-out text, shown '
            'instead of the plain story text above.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _titleController,
            label: 'Letter Title (optional override)',
            onChanged: (v) => _emit(_current.copyWith(title: v)),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _subtitleController,
            label: 'Letter Subtitle (optional override)',
            onChanged: (v) => _emit(_current.copyWith(subtitle: v)),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _bodyController,
            label: 'Letter Body',
            hint: 'My dearest…',
            maxLines: 8,
            onChanged: (v) => _emit(_current.copyWith(longLetter: v)),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _quoteController,
            label: 'Highlighted Quote (optional)',
            onChanged: (v) => _emit(_current.copyWith(quote: v)),
          ),
          const SizedBox(height: 14),
          TagInputField(
            tags: _current.highlightedWords,
            onAdd: (word) => _emit(_current.copyWith(highlightedWords: [..._current.highlightedWords, word])),
            onRemove: (word) => _emit(
              _current.copyWith(highlightedWords: _current.highlightedWords.where((w) => w != word).toList()),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Words above will be highlighted in gold wherever they appear in the letter body.',
            style: AppTextStyles.label.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _current.typingAnimationEnabled,
            activeColor: AppColors.gold,
            title: const Text('Typing animation', style: TextStyle(color: Colors.white, fontSize: 14)),
            onChanged: (v) => _emit(_current.copyWith(typingAnimationEnabled: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _current.envelopeAnimationEnabled,
            activeColor: AppColors.gold,
            title: const Text('Envelope-open animation', style: TextStyle(color: Colors.white, fontSize: 14)),
            onChanged: (v) => _emit(_current.copyWith(envelopeAnimationEnabled: v)),
          ),
        ],
      ],
    );
  }
}
