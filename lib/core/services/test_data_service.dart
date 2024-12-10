import '../../data/models/post_model.dart';
import '../../data/models/rating_model.dart';
import 'trait_service.dart';
import 'dart:math';

class TestDataService {
  static final Random _random = Random();

  static List<PostModel> generateTestPosts({int count = 10}) {
    return List.generate(count, (index) {
      final id = 'post_$index';
      final userId = index % 3 == 0 ? 'user_1' : 'user_${2 + (index % 3)}';
      final username = userId == 'user_1' ? 'Test User' : 'User ${2 + (index % 3)}';

      final ratings = List.generate(
        3,
        (rIndex) => RatingModel(
          value: 3.0 + (rIndex % 3),
          userId: 'user_${rIndex + 2}',
          createdAt: DateTime.now().subtract(Duration(days: rIndex)),
        ),
      );

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
        steps: generateTestSteps(count: 5 + _random.nextInt(3)), // 5-7 steps
        createdAt: DateTime.now().subtract(Duration(days: index)),
        likes: List.generate(index, (i) => 'user_${2 + (i % 3)}'),
        comments: List.generate(index ~/ 2, (i) => 'comment_$i'),
        status: PostStatus.active,
        ratings: ratings,
        userTraits: traits,
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static List<PostStep> generateTestSteps({int count = 3}) {
    // Define all possible step types
    final allStepTypes = StepType.values.toList();
    
    // Shuffle the step types to get random order
    allStepTypes.shuffle(_random);
    
    // Generate steps with different types
    return List.generate(
      count,
      (index) {
        // Use modulo to cycle through shuffled types
        final stepType = allStepTypes[index % allStepTypes.length];
        
        // Generate content based on step type
        final content = <String, dynamic>{};
        final stepNumber = index + 1;
        
        switch (stepType) {
          case StepType.text:
            content['text'] = 'This is step $stepNumber with text content explaining the process.';
            break;
          case StepType.image:
            content['imageUrl'] = 'https://picsum.photos/500/300?random=step_$index';
            content['caption'] = 'Image caption for step $stepNumber';
            break;
          case StepType.code:
            content['code'] = '''
void main() {
  print("Hello from step $stepNumber!");
}''';
            content['language'] = 'dart';
            break;
          case StepType.video:
            content['videoUrl'] = 'https://example.com/video$index.mp4';
            content['description'] = 'Video description for step $stepNumber';
            break;
          case StepType.audio:
            content['audioUrl'] = 'https://example.com/audio$index.mp3';
            content['description'] = 'Audio description for step $stepNumber';
            break;
          case StepType.quiz:
            content['question'] = 'What is the purpose of step $stepNumber?';
            content['options'] = [
              'Option A for step $stepNumber',
              'Option B for step $stepNumber',
              'Option C for step $stepNumber',
              'Option D for step $stepNumber'
            ];
            break;
          case StepType.ar:
            content['arModel'] = 'model$index.glb';
            content['instructions'] = 'AR instructions for step $stepNumber';
            break;
          case StepType.vr:
            content['vrScene'] = 'scene$index.gltf';
            content['instructions'] = 'VR instructions for step $stepNumber';
            break;
          case StepType.document:
            content['documentUrl'] = 'https://example.com/doc$index.pdf';
            content['summary'] = 'Document summary for step $stepNumber';
            break;
          case StepType.link:
            content['url'] = 'https://example.com/resource$index';
            content['description'] = 'External resource for step $stepNumber';
            break;
        }

        return PostStep(
          id: 'step_$index',
          title: 'Step $stepNumber',
          description: 'This is step $stepNumber',
          type: stepType,
          content: content,
        );
      },
    );
  }

  static Map<String, dynamic> generateTestAnalytics() {
    return {
      'totalViews': 1000,
      'totalLikes': 500,
      'totalComments': 250,
      'averageRating': 4.5,
      'totalPosts': 25,
      'topCategories': [
        {'name': 'cooking', 'count': 10},
        {'name': 'fitness', 'count': 8},
        {'name': 'diy', 'count': 7},
      ],
      'engagement': {
        'daily': 85,
        'weekly': 450,
        'monthly': 1800,
      },
      'userGrowth': {
        'followers': 300,
        'following': 250,
      },
    };
  }
}
