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

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isHeaderExpanded = false;
  bool _showContent = true;
  bool _isAnimatingOut = false;
  bool _showMiniatures = false;
  late List<PostStep> _allSteps;
  late AnimationController _miniatureAnimation;
  static const double _shrunkHeaderHeight = 60.0;

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

    _miniatureAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _miniatureAnimation.dispose();
    super.dispose();
  }

  void _handleHeaderExpandChange(bool expanded) {
    setState(() {
      _isHeaderExpanded = expanded;
      _showMiniatures = expanded;
      if (expanded) {
        _showContent = false;
        _isAnimatingOut = true;
        _miniatureAnimation.forward();
      } else {
        _isAnimatingOut = false;
        _showContent = false;
        _miniatureAnimation.reverse();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && !_isHeaderExpanded) {
            setState(() => _showContent = true);
          }
        });
      }
    });
  }

  void _handleTransformToMiniatures() {
    setState(() => _showMiniatures = true);
  }

  void _handleTransformToDots() {
    setState(() => _showMiniatures = false);
  }

  bool get _shouldShowHeader {
    return _currentStep == 0 || _currentStep == _allSteps.length - 1;
  }

  Widget _buildStepContent(int index, BoxConstraints constraints) {
    if (index == 0) {
      final isLiked = widget.currentUserId != null &&
          widget.post.likes.contains(widget.currentUserId);
      return Stack(
        children: [
          Positioned(
            top: constraints.maxHeight * 0.4,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    widget.post.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: widget.onLike,
              ),
            ),
          ),
        ],
      );
    } else if (index == _allSteps.length - 1) {
      final userRating = widget.currentUserId != null
          ? widget.post.getUserRating(widget.currentUserId!)?.value ?? 0.0
          : 0.0;
      return Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40), // Adjust visual center
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
              ),
            ),
          ),
        ],
      );
    } else {
      final step = widget.post.steps[index - 1];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Text(
            step.getContentValue('text') ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 32;
    final headerHeight = _isHeaderExpanded ? size * 0.75 : _shrunkHeaderHeight;
    final remainingHeight = size - headerHeight;
    final indicatorTop = _isHeaderExpanded 
        ? headerHeight + (remainingHeight / 2) - 30 
        : headerHeight - 16; // Changed from -24 to -16 to add space

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
              // Content layer with clipping
              if (!_isHeaderExpanded || _isAnimatingOut)
                Positioned.fill(
                  child: ClipRect(
                    child: AnimatedPostContent(
                      isVisible: _showContent,
                      isAnimatingOut: _isAnimatingOut,
                      topOffset: 0,
                      onAnimationComplete: _isAnimatingOut
                          ? () => setState(() {
                                _isAnimatingOut = false;
                                _showContent = false;
                              })
                          : null,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return PageView.builder(
                            itemCount: _allSteps.length,
                            onPageChanged: (index) =>
                                setState(() => _currentStep = index),
                            itemBuilder: (context, index) => 
                                _buildStepContent(index, constraints),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              // Overlay layer for header and indicators
              if (_shouldShowHeader)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight,
                  child: PostHeader(
                    username: widget.post.username,
                    userProfileImage: widget.post.userProfileImage,
                    steps: _allSteps,
                    currentStep: _currentStep,
                    isExpanded: _isHeaderExpanded,
                    onExpandChanged: _handleHeaderExpandChange,
                    userId: widget.post.userId,
                    currentPostId: widget.post.id,
                    userTraits: widget.post.userTraits,
                    rating: widget.post.ratingStats.averageRating,
                  ),
                ),
              // Step indicators layer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: indicatorTop,
                left: 0,
                right: 0,
                child: _isHeaderExpanded || _showMiniatures
                    ? StepMiniatures(
                        steps: _allSteps,
                        currentStep: _currentStep,
                        onHeaderExpandChanged: _handleHeaderExpandChange,
                        onTransformToDots: _handleTransformToDots,
                      )
                    : StepDots(
                        steps: _allSteps,
                        currentStep: _currentStep,
                        onHeaderExpandChanged: _handleHeaderExpandChange,
                        onTransformToMiniatures: _handleTransformToMiniatures,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
