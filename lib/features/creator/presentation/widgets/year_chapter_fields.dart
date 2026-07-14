import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Compact side-by-side Year + Chapter inputs. Kept as one widget since
/// they're always authored together in the Scene Editor's timeline
/// grouping section.
class YearChapterFields extends StatefulWidget {
  final int year;
  final String chapter;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onChapterChanged;

  const YearChapterFields({
    super.key,
    required this.year,
    required this.chapter,
    required this.onYearChanged,
    required this.onChapterChanged,
  });

  @override
  State<YearChapterFields> createState() => _YearChapterFieldsState();
}

class _YearChapterFieldsState extends State<YearChapterFields> {
  late final TextEditingController _yearController;
  late final TextEditingController _chapterController;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: widget.year == 0 ? '' : widget.year.toString());
    _chapterController = TextEditingController(text: widget.chapter);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant YearChapterFields oldWidget) {
    super.didUpdateWidget(oldWidget);

    final externalYearText = widget.year == 0 ? '' : widget.year.toString();
    if (externalYearText != _yearController.text) {
      _yearController.value = _yearController.value.copyWith(
        text: externalYearText,
        selection: TextSelection.collapsed(offset: externalYearText.length),
      );
    }

    if (widget.chapter != _chapterController.text) {
      _chapterController.value = _chapterController.value.copyWith(
        text: widget.chapter,
        selection: TextSelection.collapsed(offset: widget.chapter.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Year', style: AppTextStyles.label),
              const SizedBox(height: 10),
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: '2017'),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) widget.onYearChanged(parsed);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chapter', style: AppTextStyles.label),
              const SizedBox(height: 10),
              TextField(
                controller: _chapterController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Chapter 1: How We Met'),
                onChanged: widget.onChapterChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
