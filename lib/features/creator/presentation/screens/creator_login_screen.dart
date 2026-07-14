import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../settings/presentation/viewmodels/auth_viewmodel.dart';

/// Password gate protecting Creator Mode. First launch prompts the owner
/// to set a password; every subsequent visit requires it.
class CreatorLoginScreen extends ConsumerStatefulWidget {
  const CreatorLoginScreen({super.key});

  @override
  ConsumerState<CreatorLoginScreen> createState() => _CreatorLoginScreenState();
}

class _CreatorLoginScreenState extends ConsumerState<CreatorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isFirstSetup) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(authViewModelProvider.notifier);
    final success = isFirstSetup
        ? await viewModel.setPassword(_passwordController.text)
        : await viewModel.verifyPassword(_passwordController.text);

    if (success && mounted) {
      context.pushReplacement(AppRoutes.creatorDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isFirstSetup = !authState.hasCreatorPassword;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.romanticGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.gold, size: 44),
                  const SizedBox(height: 20),
                  Text(
                    isFirstSetup ? 'Set a Creator Password' : 'Creator Mode',
                    style: AppTextStyles.sceneTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFirstSetup
                        ? 'This protects your private editing space.'
                        : 'Enter your password to continue editing.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  if (isFirstSetup) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Confirm Password',
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                  ],
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      authState.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 28),
                  AppButton(
                    label: isFirstSetup ? 'Create Password' : 'Unlock',
                    isLoading: authState.status == AuthStatus.checking,
                    onPressed: () => _submit(isFirstSetup),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Back',
                    variant: AppButtonVariant.text,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
