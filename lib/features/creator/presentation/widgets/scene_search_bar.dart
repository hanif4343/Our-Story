import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Live search field for the Scene List. Filtering itself happens in
/// [CreatorViewModel] against title/subtitle/story/chapter/tags.
///
/// Owns its [TextEditingController] internally (rather than rebuilding
/// one from [value] on every parent rebuild) so typing never loses
/// cursor position or focus while the ViewModel's state updates.
class SceneSearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SceneSearchBar({super.key, required this.value, required this.onChanged});

  @override
  State<SceneSearchBar> createState() => _SceneSearchBarState();
}

class _SceneSearchBarState extends State<SceneSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SceneSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync if the value changed externally (e.g. a "clear
    // filters" action) — never while the field itself still matches,
    // which would otherwise fight the user's cursor while typing.
    if (widget.value != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search scenes, tags, chapters…',
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedWhite, size: 20),
        suffixIcon: widget.value.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: AppColors.mutedWhite, size: 18),
                onPressed: () => widget.onChanged(''),
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }
}
