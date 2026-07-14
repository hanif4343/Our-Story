import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/timeline/presentation/screens/journey_intro_screen.dart';
import '../../features/creator/presentation/screens/creator_login_screen.dart';
import '../../features/creator/presentation/screens/creator_dashboard_screen.dart';
import '../../features/creator/presentation/screens/creator_home_screen.dart';
import '../../features/creator/presentation/screens/chapter_list_screen.dart';
import '../../features/creator/presentation/screens/scene_editor_screen.dart';
import '../../features/creator/presentation/screens/scene_preview_screen.dart';
import '../../features/story/presentation/screens/story_intro_screen.dart';
import '../../features/story/presentation/screens/story_player_screen.dart';
import '../../features/timeline/presentation/screens/cinematic_timeline_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/creator/domain/entities/scene.dart';

/// Central route table. Screens never construct their own navigation
/// paths as raw strings elsewhere — always via [AppRoutes].
class AppRoutes {
  AppRoutes._();

  static const String intro = '/intro';
  static const String home = '/';
  static const String creatorLogin = '/creator/login';
  static const String creatorDashboard = '/creator/dashboard';
  static const String creatorHome = '/creator';
  static const String chapterList = '/creator/chapters';
  static const String sceneCreate = '/creator/scene/new';
  static const String sceneEdit = '/creator/scene/edit';
  static const String scenePreview = '/creator/scene/preview';
  static const String storyIntro = '/story';
  static const String storyPlayer = '/story/play';
  static const String cinematicTimeline = '/timeline';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.intro,
  routes: [
    GoRoute(
      path: AppRoutes.intro,
      builder: (context, state) => const JourneyIntroScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorLogin,
      builder: (context, state) => const CreatorLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorDashboard,
      builder: (context, state) => const CreatorDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.creatorHome,
      builder: (context, state) => const CreatorHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.chapterList,
      builder: (context, state) => const ChapterListScreen(),
    ),
    GoRoute(
      path: AppRoutes.sceneCreate,
      builder: (context, state) => const SceneEditorScreen(scene: null),
    ),
    GoRoute(
      path: AppRoutes.sceneEdit,
      builder: (context, state) => SceneEditorScreen(scene: state.extra as Scene?),
    ),
    GoRoute(
      path: AppRoutes.scenePreview,
      builder: (context, state) => ScenePreviewScreen(scene: state.extra as Scene),
    ),
    GoRoute(
      path: AppRoutes.storyIntro,
      builder: (context, state) => const StoryIntroScreen(),
    ),
    GoRoute(
      path: AppRoutes.storyPlayer,
      builder: (context, state) => const StoryPlayerScreen(),
    ),
    GoRoute(
      path: AppRoutes.cinematicTimeline,
      builder: (context, state) => const CinematicTimelineScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
