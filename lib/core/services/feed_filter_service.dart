import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';

class FeedFilterService {
  List<PostModel> filterPosts(List<PostModel> posts, UserModel currentUser) {
    return posts.where((post) => _shouldShowPost(post, currentUser)).toList();
  }

  bool _shouldShowPost(PostModel post, UserModel currentUser) {
    // Check if post is active
    if (post.status != PostStatus.active) {
      return false;
    }

    // Check targeting criteria
    if (post.targetingCriteria != null &&
        currentUser.targetingCriteria != null) {
      if (!post.isTargetedTo(currentUser.targetingCriteria!)) {
        return false;
      }
    }

    return true;
  }
}
