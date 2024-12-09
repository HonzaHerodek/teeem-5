import '../../data/models/post_model.dart';
import '../../data/models/rating_model.dart';
import 'trait_service.dart';

class TestDataService {
  static List<PostModel> generateTestPosts({int count = 10}) {
    return List.generate(count, (index) {
      final id = 'post_$index';
      final userId = index % 3 == 0 ? 'user_1' : 'user_${2 + (index % 3)}';
      final username = userId == 'user_1' ? 'Test User' : 'User ${2 + (index % 3)}';

      // Generate test ratings for each post
      final ratings = List.generate(
        3,
        (rIndex) => RatingModel(
          value: 3.0 + (rIndex % 3),
          userId: 'user_${rIndex + 2}',
          createdAt: DateTime.now().subtract(Duration(days: rIndex)),
        ),
      );

      // Get traits based on post type
      final category = switch (index % 4) {
        0 => 'cooking',
        1 => 'diy',
        2 => 'fitness',
        3 => 'programming',
        _ => 'general',
      };
      final traits = TraitService.getTraitsForCategory(category);

      return PostModel(
        id: id,
        userId: userId,
        username: username,
        userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
        title: 'Test Post $index',
        description: 'Test description for post $index',
        steps: generateTestSteps(),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        likes: List.generate(index, (i) => 'user_${2 + (i % 3)}'),
        comments: List.generate(index ~/ 2, (i) => 'comment_$i'),
        status: PostStatus.active,
        ratings: ratings,
        userTraits: traits,
      );
    });
  }

  static List<PostStep> generateTestSteps({int count = 3}) {
    return List.generate(
      count,
      (index) => PostStep(
        id: 'step_$index',
        title: 'Step ${index + 1}',
        description: 'This is step ${index + 1}',
        type: StepType.values[index % StepType.values.length],
        content: {
          'text': 'Sample content for step ${index + 1}',
          'imageUrl': 'https://picsum.photos/500/300?random=step_$index',
        },
      ),
    );
  }
}
