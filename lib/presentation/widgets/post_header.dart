import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/models/trait_model.dart';
import '../../domain/repositories/post_repository.dart';
import '../../core/di/injection.dart';
import '../../core/navigation/navigation_service.dart';
import 'rating_stars.dart';
import 'user_traits.dart';

class PostHeader extends StatefulWidget {
  final String username;
  final String? userProfileImage;
  final List<PostStep> steps;
  final int currentStep;
  final bool isExpanded;
  final Function(bool) onExpandChanged;
  final String userId;
  final String currentPostId;
  final Function(double)? onAnimationChanged;
  final List<TraitModel> userTraits;

  const PostHeader({
    super.key,
    required this.username,
    this.userProfileImage,
    required this.steps,
    required this.currentStep,
    required this.isExpanded,
    required this.onExpandChanged,
    required this.userId,
    required this.currentPostId,
    this.onAnimationChanged,
    this.userTraits = const [],
  });

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> with SingleTickerProviderStateMixin {
  List<PostModel>? _otherPosts;
  bool _isLoadingPosts = false;
  static const double _miniatureSize = 80.0;
  static const double _horizontalMargin = 8.0;
  static const double _starSize = 14.0;
  static const double _collapsedAvatarSize = 38.4;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _controller.addListener(() {
      widget.onAnimationChanged?.call(_controller.value);
    });
    
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PostHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (!oldWidget.isExpanded && widget.isExpanded) {
      _fetchOtherPosts();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherPosts() async {
    if (_isLoadingPosts) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await getIt<PostRepository>().getPosts(
        userId: widget.userId,
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          _otherPosts = posts.where((post) => post.id != widget.currentPostId).toList();
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  void _navigateToPost(PostModel post) {
    getIt<NavigationService>().navigateTo(
      AppRoutes.feed,
      arguments: {'postId': post.id},
    );
  }

  Widget _buildOtherPostThumbnail(PostModel post) {
    return GestureDetector(
      onTap: () => _navigateToPost(post),
      child: Container(
        width: _miniatureSize,
        margin: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _miniatureSize,
              height: _miniatureSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF2A1635).withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post.title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: _miniatureSize,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isHalfStar = post.ratingStats.averageRating > index && 
                                   post.ratingStats.averageRating < starValue;
                  final isFullStar = post.ratingStats.averageRating >= starValue;

                  return Icon(
                    isFullStar
                        ? Icons.star
                        : isHalfStar
                            ? Icons.star_half
                            : Icons.star_border,
                    size: _starSize,
                    color: Colors.amber,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showProfilePicture => widget.currentStep == 0 || widget.currentStep == widget.steps.length - 1;

  Widget _buildProfilePicture(double headerHeight, double postSize) {
    if (!_showProfilePicture || widget.userProfileImage == null) return Container();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final expandProgress = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ).value;

        if (expandProgress == 1) {
          return Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(999),
                  bottom: Radius.circular(postSize / 2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(999),
                  bottom: Radius.circular(postSize / 2),
                ),
                child: Image.network(
                  widget.userProfileImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        widget.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          final size = Tween<double>(
            begin: _collapsedAvatarSize,
            end: headerHeight,
          ).evaluate(_controller);

          final top = Tween<double>(
            begin: 20,
            end: 0,
          ).evaluate(_controller);

          return Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.userProfileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          widget.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postSize = MediaQuery.of(context).size.width - 32;
    final expandedHeight = postSize * 0.75;
    final headerHeight = widget.isExpanded ? expandedHeight : 120.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(999),
                  bottom: Radius.circular(widget.isExpanded ? postSize / 2 : 0),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: const Radius.circular(999),
                        bottom: Radius.circular(widget.isExpanded ? postSize / 2 : 0),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7 * _controller.value),
                          Colors.black.withOpacity(0.5 * _controller.value),
                          Colors.black.withOpacity(0.7 * _controller.value),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            _buildProfilePicture(headerHeight, postSize),
            if (widget.isExpanded)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controller.value == 1.0 ? 1.0 : 0.0,
                    child: Positioned.fill(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Rating stars at the top
                          RatingStars(
                            rating: 4.5,
                            size: 32,
                            color: Colors.amber,
                          ),
                          const Spacer(),
                          // User traits in the middle
                          if (widget.userTraits.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: UserTraits(
                                traits: widget.userTraits,
                                height: 120,
                              ),
                            ),
                          const Spacer(),
                          // Other posts at the bottom
                          if (_otherPosts != null && _otherPosts!.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _otherPosts!.length,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) => _buildOtherPostThumbnail(
                                  _otherPosts![index],
                                ),
                              ),
                            )
                          else if (_isLoadingPosts)
                            const SizedBox(
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onExpandChanged(!widget.isExpanded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
