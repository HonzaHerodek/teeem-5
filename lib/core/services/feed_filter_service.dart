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
      if (!post.isTargetedTo(currentUser)) {
        return false;
      }
    }

    // Check if post is from blocked user (to be implemented)
    // if (_isUserBlocked(post.userId, currentUser)) {
    //   return false;
    // }

    // Check if post is hidden by user (to be implemented)
    // if (_isPostHidden(post.id, currentUser)) {
    //   return false;
    // }

    // Check content maturity rating (to be implemented)
    // if (!_isContentAllowed(post.maturityRating, currentUser.contentPreferences)) {
    //   return false;
    // }

    // Check language preferences (to be implemented)
    // if (!_isLanguageAllowed(post.language, currentUser.languagePreferences)) {
    //   return false;
    // }

    // Add more filtering criteria here as needed

    return true;
  }

  // Helper methods for future implementation
  // bool _isUserBlocked(String userId, UserModel currentUser) {
  //   return currentUser.blockedUsers?.contains(userId) ?? false;
  // }

  // bool _isPostHidden(String postId, UserModel currentUser) {
  //   return currentUser.hiddenPosts?.contains(postId) ?? false;
  // }

  // bool _isContentAllowed(String? maturityRating, UserContentPreferences? prefs) {
  //   if (maturityRating == null || prefs == null) return true;
  //   return prefs.allowedMaturityRatings.contains(maturityRating);
  // }

  // bool _isLanguageAllowed(String? language, UserLanguagePreferences? prefs) {
  //   if (language == null || prefs == null) return true;
  //   return prefs.preferredLanguages.contains(language);
  // }
}
