import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../creator/domain/entities/letter.dart';

/// Renders a scene's [Letter] reveal: an optional tap-to-open envelope
/// animation (auto-opens on its own after a moment too, so Story Mode's
/// autoplay is never blocked waiting for a tap) with a paper-unfold
/// beat, then the letter body typed out character by character, with
/// specific words rendered highlighted in gold and an optional standout
/// quote.
///
/// Used by [SceneView] whenever `Scene.letter` is present — falls back
/// to the scene's plain title/subtitle/storyText otherwise (unchanged
/// v1.1.0 behaviour), so this widget only ever needs to handle the
/// "has a letter" case.
class LetterView extends StatefulWidget {
  final Letter letter;
  final String fallbackTitle;
  final String fallbackSubtitle;

  const LetterView({
    super.key,
    required this.letter,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
  });

  @override
  State<LetterView> createState() => _LetterViewState();
}

enum _RevealStage { envelope, unfolding, letter }

class _LetterViewState extends State<LetterView> with SingleTickerProviderStateMixin {
  late final AnimationController _envelopeController;
  _RevealStage _stage = _RevealStage.envelope;
  Timer? _typingTimer;
  Timer? _autoOpenTimer;
  int _visibleCharCount = 0;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String get _body => widget.letter.longLetter;

  @override
  void initState() {
    super.initState();
    _envelopeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    if (widget.letter.envelopeAnimationEnabled) {
      // Auto-opens on its own so Story Mode's autoplay is never stuck
      // waiting for a tap — a tap just opens it sooner (see [_openEnvelope]).
      _autoOpenTimer = Timer(const Duration(milliseconds: 1400), _openEnvelope);
    } else {
      _stage = _RevealStage.letter;
      _revealBody();
    }
  }

  void _openEnvelope() {
    if (!mounted || _stage != _RevealStage.envelope) return;
    _autoOpenTimer?.cancel();
    _playSoftPaperSound();
    _envelopeController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _stage = _RevealStage.unfolding);
      // Brief paper-unfold beat before the text starts typing.
      Timer(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        setState(() => _stage = _RevealStage.letter);
        _revealBody();
      });
    });
  }

  /// Best-effort paper-rustle sound. Ships without a bundled sound
  /// effect (binary audio can't be authored as source code) — dropping
  /// a file at `assets/audio/paper_open.mp3` activates it automatically.
  Future<void> _playSoftPaperSound() async {
    try {
      await _sfxPlayer.play(AssetSource(AssetPaths.paperOpenSound.replaceFirst('assets/', '')));
    } catch (_) {
      // No sound effect bundled yet — the visual reveal still plays.
    }
  }

  void _revealBody() {
    if (!widget.letter.typingAnimationEnabled || _body.isEmpty) {
      setState(() => _visibleCharCount = _body.length);
      return;
    }

    const perCharacter = Duration(milliseconds: 28);
    _typingTimer = Timer.periodic(perCharacter, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleCharCount >= _body.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleCharCount++);
    });
  }

  @override
  void dispose() {
    _envelopeController.dispose();
    _typingTimer?.cancel();
    _autoOpenTimer?.cancel();
    _sfxPlayer.dispose();
    super.dispose();
  }

  /// Splits [text] into spans, rendering any word/phrase from
  /// [highlightedWords] in gold semi-bold, matched case-insensitively.
  List<TextSpan> _buildHighlightedSpans(String text, List<String> highlightedWords) {
    if (highlightedWords.isEmpty) return [TextSpan(text: text)];

    final pattern = highlightedWords.where((w) => w.trim().isNotEmpty).map(RegExp.escape).join('|');
    if (pattern.isEmpty) return [TextSpan(text: text)];

    final regex = RegExp(pattern, caseSensitive: false);
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.letter.title?.trim().isNotEmpty == true ? widget.letter.title! : widget.fallbackTitle;
    final subtitle =
        widget.letter.subtitle?.trim().isNotEmpty == true ? widget.letter.subtitle! : widget.fallbackSubtitle;
    final visibleBody = _body.substring(0, _visibleCharCount.clamp(0, _body.length));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: switch (_stage) {
        _RevealStage.envelope => GestureDetector(
            key: const ValueKey('envelope'),
            behavior: HitTestBehavior.opaque,
            onTap: _openEnvelope,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EnvelopeGraphic(controller: _envelopeController),
                const SizedBox(height: 14),
                Text('Tap to open', style: AppTextStyles.label.copyWith(color: AppColors.mutedWhite)),
              ],
            ),
          ),
        _RevealStage.unfolding => TweenAnimationBuilder<double>(
            key: const ValueKey('unfolding'),
            tween: Tween(begin: 0.15, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scaleY: value,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            ),
            child: Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12)],
              ),
            ),
          ),
        _RevealStage.letter => Column(
            key: const ValueKey('letter'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
              if (subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              if (visibleBody.isNotEmpty)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.storyBody,
                    children: _buildHighlightedSpans(visibleBody, widget.letter.highlightedWords),
                  ),
                ),
              if (widget.letter.quote?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 18),
                Text(
                  '“${widget.letter.quote!.trim()}”',
                  style: AppTextStyles.storyBody.copyWith(color: AppColors.gold, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
      },
    );
  }
}

class _EnvelopeGraphic extends StatelessWidget {
  final AnimationController controller;
  const _EnvelopeGraphic({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final flapAngle = Curves.easeInOut.transform(controller.value) * 3.14159;
        final lift = Curves.easeInOut.transform(controller.value) * -18;
        return Transform.translate(
          offset: Offset(0, lift),
          child: SizedBox(
            width: 96,
            height: 68,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 96,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                  ),
                ),
                Positioned(
                  top: -2,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()..rotateX(flapAngle > 1.57 ? 3.14159 - flapAngle : flapAngle),
                    child: CustomPaint(
                      size: const Size(96, 40),
                      painter: _EnvelopeFlapPainter(),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 14,
                  child: Icon(Icons.favorite, color: AppColors.rosePink, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.rosePinkDark
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
