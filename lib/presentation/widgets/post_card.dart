import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'rating_stars.dart';
import 'post_header.dart';
import 'animated_post_content.dart';
import 'step_indicators.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String? currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final Function(double) onRate;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onRate,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentStep = 0;
  bool _isHeaderExpanded = false;
  bool _showContent = true;
  bool _isAnimatingOut = false;
  late List<PostStep> _allSteps;

  @override
  void initState() {
    super.initState();
    _allSteps = [
      PostStep(
        id: '${widget.post.id}_intro',
        title: widget.post.title,
        description: widget.post.description,
        type: StepType.text,
        content: {'text': widget.post.description},
      ),
      ...widget.post.steps,
      PostStep(
        id: '${widget.post.id}_outro',
        title: 'Rate and Share',
        description: 'Rate and share this post',
        type: StepType.text,
        content: {'text': ''},
      ),
    ];
  }

  Widget _buildStepContent(int index) {
    if (index == 0) {
      final isLiked = widget.currentUserId != null &&
          widget.post.likes.contains(widget.currentUserId);
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      widget.post.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.post.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: widget.onLike,
              ),
            ],
          ),
        ),
      );
    } else if (index == _allSteps.length - 1) {
      final userRating = widget.currentUserId != null
          ? widget.post.getUserRating(widget.currentUserId!)?.value ?? 0.0
          : 0.0;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rate this post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              RatingStars(
                rating: userRating,
                onRatingChanged: widget.onRate,
                isInteractive: true,
                size: 32,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: widget.onShare,
              ),
            ],
          ),
        ),
      );
    } else {
      final step = widget.post.steps[index - 1];
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            step.getContentValue('text') ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 32;
    final headerHeight = _isHeaderExpanded ? size * 0.75 : 120.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      width: size,
      height: size,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 35,
            spreadRadius: 8,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF2A1635).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Content
              if (!_isHeaderExpanded || _isAnimatingOut)
                AnimatedPostContent(
                  isVisible: _showContent,
                  isAnimatingOut: _isAnimatingOut,
                  topOffset: headerHeight,
                  onAnimationComplete: _isAnimatingOut
                      ? () => setState(() {
                            _isAnimatingOut = false;
                            _showContent = false;
                          })
                      : null,
                  child: PageView.builder(
                    itemCount: _allSteps.length,
                    onPageChanged: (index) =>
                        setState(() => _currentStep = index),
                    itemBuilder: (context, index) => _buildStepContent(index),
                  ),
                ),
              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PostHeader(
                  username: widget.post.username,
                  userProfileImage: widget.post.userProfileImage,
                  steps: _allSteps,
                  currentStep: _currentStep,
                  isExpanded: _isHeaderExpanded,
                  onExpandChanged: (expanded) {
                    setState(() {
                      _isHeaderExpanded = expanded;
                      if (expanded) {
                        _showContent = false;
                        _isAnimatingOut = true;
                      } else {
                        _isAnimatingOut = false;
                        // Start with content hidden
                        _showContent = false;
                        // Show content after a tiny delay to ensure animation starts with header
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (mounted && !_isHeaderExpanded) {
                            setState(() => _showContent = true);
                          }
                        });
                      }
                    });
                  },
                  userId: widget.post.userId,
                  currentPostId: widget.post.id,
                  userTraits: widget.post.userTraits,
                  rating: widget.post.ratingStats.averageRating,
                ),
              ),
              // Step dots (only visible when header is shrinked)
              if (!_isHeaderExpanded)
                Positioned(
                  top: headerHeight - 32,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: StepDots(
                      steps: _allSteps,
                      currentStep: _currentStep,
                      animation: const AlwaysStoppedAnimation(1.0),
                    ),
                  ),
                ),
              // Step miniatures (visible when header is expanded)
              if (_isHeaderExpanded && !_showContent)
                Positioned(
                  top: headerHeight + 16,
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: StepMiniatures(
                      steps: _allSteps,
                      currentStep: _currentStep,
                      animation: const AlwaysStoppedAnimation(1.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
