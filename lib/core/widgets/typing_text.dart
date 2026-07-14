import 'dart:async';
import 'package:flutter/material.dart';

/// Reveals [text] one character at a time, like a typewriter. Shared by
/// [JourneyIntroScreen]'s "Our Story" title card and [LetterView]'s
/// letter-body reveal — one implementation instead of two copies of the
/// same `Timer.periodic` logic.
class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration characterDuration;
  final Duration startDelay;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.characterDuration = const Duration(milliseconds: 60),
    this.startDelay = Duration.zero,
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  int _visibleCount = 0;
  Timer? _timer;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _startTimer = Timer(widget.startDelay, _startTyping);
  }

  void _startTyping() {
    if (!mounted) return;
    _timer = Timer.periodic(widget.characterDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleCount >= widget.text.length) {
        timer.cancel();
        widget.onComplete?.call();
        return;
      }
      setState(() => _visibleCount++);
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.text.substring(0, _visibleCount.clamp(0, widget.text.length));
    return Text(visible, style: widget.style, textAlign: widget.textAlign);
  }
}
