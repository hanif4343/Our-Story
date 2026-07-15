import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/typing_text.dart';
import '../../../animation/sparkle/sparkle_overlay.dart';
import '../../../animation/stars/stars_overlay.dart';
import '../viewmodels/journey_viewmodel.dart';

/// The cinematic sequence that opens the app, before Home: a dark,
/// star-filled stage, "Our Story" typed out, then the couple's names
/// and wedding date revealed in sequence, then a "Begin Journey"
/// button. Plays once per launch — [AppRoutes.intro] is the router's
/// `initialLocation`; finishing (or skipping) takes the person to the
/// unchanged [HomeScreen] via `context.go`.
class JourneyIntroScreen extends ConsumerStatefulWidget {
  const JourneyIntroScreen({super.key});

  @override
  ConsumerState<JourneyIntroScreen> createState() => _JourneyIntroScreenState();
}

enum _IntroStage { stage0Empty, titleTyping, names, weddingDate, button }

class _JourneyIntroScreenState extends ConsumerState<JourneyIntroScreen> {
  _IntroStage _stage = _IntroStage.stage0Empty;
  final AudioPlayer _musicPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAmbientMusic();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _stage = _IntroStage.titleTyping);
    });
  }

  /// Best-effort ambient piano loop. This ships without a bundled audio
  /// asset (binary audio can't be authored as source code) — dropping a
  /// file at `assets/audio/ambient_theme.mp3` activates it automatically;
  /// until then this silently no-ops rather than crashing the intro.
  Future<void> _playAmbientMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.4);
      await _musicPlayer.play(AssetSource(
        AssetPaths.defaultAmbientMusic.replaceFirst('assets/', ''),
      ));
    } catch (_) {
      // No ambient track bundled yet — the cinematic visuals still play.
    }
  }

  void _onTitleTypingComplete() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _stage = _IntroStage.names);
    });
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _stage = _IntroStage.weddingDate);
    });
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) setState(() => _stage = _IntroStage.button);
    });
  }

  void _begin() {
    _musicPlayer.stop();
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }

  bool _stageAtLeast(_IntroStage target) => _stage.index >= target.index;

  @override
  Widget build(BuildContext context) {
    final journey = ref.watch(journeyViewModelProvider);
    final partnerOne = journey?.partnerOneName ?? '';
    final partnerTwo = journey?.partnerTwoName ?? '';
    final weddingDate = journey?.weddingDate;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
          const StarsOverlay(),
          const Opacity(opacity: 0.6, child: SparkleOverlay(particleCount: 10)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  if (_stageAtLeast(_IntroStage.titleTyping))
                    TypingText(
                      text: 'Our Story',
                      style: AppTextStyles.heroTitle,
                      characterDuration: const Duration(milliseconds: 130),
                      onComplete: _onTitleTypingComplete,
                    ),
                  const SizedBox(height: 36),
                  AnimatedOpacity(
                    opacity: _stageAtLeast(_IntroStage.names) ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset: _stageAtLeast(_IntroStage.names) ? Offset.zero : const Offset(0, 0.15),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOut,
                      child: partnerOne.isEmpty && partnerTwo.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                if (partnerOne.isNotEmpty)
                                  Text(partnerOne, style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
                                const SizedBox(height: 10),
                                const Icon(Icons.favorite, color: AppColors.rosePink, size: 22),
                                const SizedBox(height: 10),
                                if (partnerTwo.isNotEmpty)
                                  Text(partnerTwo, style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedOpacity(
                    opacity: _stageAtLeast(_IntroStage.weddingDate) && weddingDate != null ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: weddingDate == null
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              const Text('Wedding Date', style: AppTextStyles.label, textAlign: TextAlign.center),
                              const SizedBox(height: 6),
                              Text(
                                DateFormatter.scene(weddingDate),
                                style: AppTextStyles.sceneDate,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const Spacer(flex: 3),
                  AnimatedOpacity(
                    opacity: _stageAtLeast(_IntroStage.button) ? 1 : 0,
                    duration: const Duration(milliseconds: 700),
                    child: IgnorePointer(
                      ignoring: !_stageAtLeast(_IntroStage.button),
                      child: AppButton(
                        label: 'Begin Journey',
                        icon: Icons.arrow_forward_rounded,
                        expand: true,
                        onPressed: _begin,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: _begin,
                child: const Text('Skip', style: TextStyle(color: AppColors.mutedWhite)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
