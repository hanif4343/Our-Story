import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';

/// Cinematic title card shown before the story begins playing — sets the
/// mood, exactly like a film's opening title sequence.
class StoryIntroScreen extends StatelessWidget {
  const StoryIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.romanticGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Opacity(opacity: value, child: child),
                  child: const Text(AppConstants.appName, style: AppTextStyles.heroTitle, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 14),
                const Text(AppConstants.appTagline, style: AppTextStyles.sceneDate, textAlign: TextAlign.center),
                const Spacer(flex: 3),
                AppButton(
                  label: 'Play',
                  icon: Icons.play_arrow_rounded,
                  expand: true,
                  onPressed: () => context.pushReplacement(AppRoutes.storyPlayer),
                ),
                const SizedBox(height: 12),
                AppButton(label: 'Not Now', variant: AppButtonVariant.text, onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
