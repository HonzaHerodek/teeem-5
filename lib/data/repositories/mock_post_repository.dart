import 'dart:async';
import '../../core/errors/app_exception.dart';
import '../../core/services/test_data_service.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';
import '../models/rating_model.dart';

class MockPostRepository implements PostRepository {
  final List<PostModel> _posts = [];
  final _delay = const Duration(milliseconds: 500); // Simulate network delay

  MockPostRepository() {
    // Initialize with test data
    _initializeTestPosts();
  }

  void _initializeTestPosts() {
    // Create some test ratings
    final testRatings = [
      RatingModel(
        value: 4.5,
        userId: 'user_2',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RatingModel(
        value: 5.0,
        userId: 'user_3',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RatingModel(
        value: 4.0,
        userId: 'user_4',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    // Add some test posts for user_1 (test user)
    _posts.addAll([
      PostModel(
        id: 'post_1',
        userId: 'user_1',
        username: 'Test User',
        userProfileImage: 'https://i.pravatar.cc/150?u=test@example.com',
        title: 'My First Flutter App',
        description:
            'A step-by-step guide to building your first Flutter application',
        steps: [
          PostStep(
            id: 'step_1',
            title: 'Setup Flutter',
            description:
                'Install Flutter and set up your development environment',
            type: StepType.text,
            content: {
              'text': 'Follow the official Flutter installation guide...',
            },
          ),
          PostStep(
            id: 'step_2',
            title: 'Create Project',
            description: 'Create a new Flutter project',
            type: StepType.code,
            content: {
              'code': 'flutter create my_app',
              'language': 'bash',
            },
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: ['user_2', 'user_3'],
        comments: ['comment_1', 'comment_2'],
        status: PostStatus.active,
        ratings: testRatings,
      ),
      PostModel(
        id: 'post_2',
        userId: 'user_1',
        username: 'Test User',
        userProfileImage: 'https://i.pravatar.cc/150?u=test@example.com',
        title: 'State Management in Flutter',
        description:
            'Understanding different state management approaches in Flutter',
        steps: [
          PostStep(
            id: 'step_1',
            title: 'What is State?',
            description: 'Understanding state in Flutter applications',
            type: StepType.text,
            content: {
              'text': 'State in Flutter represents the data that can change...',
            },
          ),
          PostStep(
            id: 'step_2',
            title: 'Using BLoC',
            description: 'Implementing BLoC pattern',
            type: StepType.code,
            content: {
              'code': '''
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}''',
              'language': 'dart',
            },
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: ['user_2'],
        comments: ['comment_3'],
        status: PostStatus.active,
        ratings: [
          RatingModel(
            value: 5.0,
            userId: 'user_2',
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          RatingModel(
            value: 4.5,
            userId: 'user_3',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),
    ]);

    // Add test posts from TestDataService with ratings
    final generatedPosts = TestDataService.generateTestPosts(count: 10);
    for (var post in generatedPosts) {
      final ratings = List.generate(
        3,
        (index) => RatingModel(
          value: 3.0 + index.toDouble(),
          userId: 'user_${index + 2}',
          createdAt: DateTime.now().subtract(Duration(days: index)),
        ),
      );
      _posts.add(post.copyWith(ratings: ratings));
    }
  }

  @override
  Future<List<PostModel>> getPosts({
    int? limit,
    String? startAfter,
    String? userId,
    List<String>? tags,
  }) async {
    await Future.delayed(_delay);

    var filteredPosts = List<PostModel>.from(_posts);

    if (userId != null) {
      filteredPosts =
          filteredPosts.where((post) => post.userId == userId).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) {
        final postTags = post.aiMetadata?['tags'] as List?;
        return postTags?.any((tag) => tags.contains(tag)) ?? false;
      }).toList();
    }

    if (startAfter != null) {
      final startIndex =
          filteredPosts.indexWhere((post) => post.id == startAfter);
      if (startIndex != -1 && startIndex < filteredPosts.length - 1) {
        filteredPosts = filteredPosts.sublist(startIndex + 1);
      }
    }

    // Sort by creation date, newest first
    filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null) {
      filteredPosts = filteredPosts.take(limit).toList();
    }

    return filteredPosts;
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    return post;
  }

  @override
  Future<void> createPost(PostModel post) async {
    await Future.delayed(_delay);

    // Ensure the post has all required fields
    if (post.userId.isEmpty) {
      throw ValidationException('Post must have a user ID');
    }
    if (post.steps.isEmpty) {
      throw ValidationException('Post must have at least one step');
    }

    // Add the post to the beginning of the list (newest first)
    _posts.insert(0, post);
  }

  @override
  Future<void> updatePost(PostModel post) async {
    await Future.delayed(_delay);

    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index == -1) {
      throw NotFoundException('Post not found');
    }

    _posts[index] = post;
  }

  @override
  Future<void> deletePost(String postId) async {
    await Future.delayed(_delay);

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw NotFoundException('Post not found');
    }
    _posts.removeAt(index);
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    if (!post.likes.contains(userId)) {
      final updatedPost = post.copyWith(
        likes: List.of(post.likes)..add(userId),
      );
      await updatePost(updatedPost);
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    if (post.likes.contains(userId)) {
      final updatedPost = post.copyWith(
        likes: List.of(post.likes)..remove(userId),
      );
      await updatePost(updatedPost);
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String comment) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    final updatedPost = post.copyWith(
      comments: List.of(post.comments)..add('comment_${post.comments.length}'),
    );
    await updatePost(updatedPost);
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    final updatedPost = post.copyWith(
      comments: List.of(post.comments)..remove(commentId),
    );
    await updatePost(updatedPost);
  }

  @override
  Future<void> updatePostStep(
    String postId,
    String stepId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    final updatedSteps = post.steps.map((step) {
      if (step.id == stepId) {
        return PostStep(
          id: step.id,
          title: data['title'] ?? step.title,
          description: data['description'] ?? step.description,
          type: step.type,
          content: {...step.content, ...data['content'] ?? {}},
        );
      }
      return step;
    }).toList();

    final updatedPost = post.copyWith(steps: updatedSteps);
    await updatePost(updatedPost);
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    await Future.delayed(_delay);

    final queryLower = query.toLowerCase();
    return _posts.where((post) {
      return post.title?.toLowerCase().contains(queryLower) ??
          false || post.description.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  Future<List<PostModel>> getTrendingPosts({int? limit}) async {
    await Future.delayed(_delay);

    final sortedPosts = List<PostModel>.from(_posts)
      ..sort((a, b) => b.likes.length.compareTo(a.likes.length));

    if (limit != null) {
      return sortedPosts.take(limit).toList();
    }
    return sortedPosts;
  }

  @override
  Future<List<PostModel>> getRecommendedPosts({
    required String userId,
    int? limit,
  }) async {
    // For mock data, just return trending posts
    return getTrendingPosts(limit: limit);
  }

  @override
  Future<List<PostModel>> getUserFeed({
    required String userId,
    int? limit,
    String? startAfter,
  }) async {
    // For mock data, just return all posts
    return getPosts(limit: limit, startAfter: startAfter);
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    await Future.delayed(_delay);
    // In mock implementation, just log the report
    print('Post $postId reported by $userId for reason: $reason');
  }

  @override
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    await Future.delayed(_delay);
    return TestDataService.generateTestAnalytics();
  }

  @override
  Future<void> hidePost(String postId, String userId) async {
    await Future.delayed(_delay);
    // In mock implementation, just log the hide action
    print('Post $postId hidden by $userId');
  }

  @override
  Future<void> savePost(String postId, String userId) async {
    await Future.delayed(_delay);
    // In mock implementation, just log the save action
    print('Post $postId saved by $userId');
  }

  @override
  Future<void> unsavePost(String postId, String userId) async {
    await Future.delayed(_delay);
    // In mock implementation, just log the unsave action
    print('Post $postId unsaved by $userId');
  }

  @override
  Future<List<String>> getPostTags(String postId) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    return List<String>.from(post.aiMetadata?['tags'] ?? []);
  }

  @override
  Future<void> updatePostTags(String postId, List<String> tags) async {
    await Future.delayed(_delay);

    final post = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw NotFoundException('Post not found'),
    );

    final updatedPost = post.copyWith(
      aiMetadata: {...post.aiMetadata ?? {}, 'tags': tags},
    );
    await updatePost(updatedPost);
  }
}
