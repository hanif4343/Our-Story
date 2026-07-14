import '../../../creator/data/datasources/scene_local_datasource.dart';
import '../../../creator/data/models/scene_model.dart';

/// Thin read-only wrapper around [SceneLocalDataSource] for Story Mode.
abstract class StoryLocalDataSource {
  List<SceneModel> getTimeline();
}

class StoryLocalDataSourceImpl implements StoryLocalDataSource {
  final SceneLocalDataSource sceneLocalDataSource;
  StoryLocalDataSourceImpl(this.sceneLocalDataSource);

  @override
  List<SceneModel> getTimeline() => sceneLocalDataSource.getAllScenes();
}
