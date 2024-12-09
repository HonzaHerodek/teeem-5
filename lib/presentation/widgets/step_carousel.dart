import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepCarousel extends StatefulWidget {
  final List<PostStep> steps;
  final bool showArrows;
  final Function(int)? onPageChanged;

  const StepCarousel({
    super.key,
    required this.steps,
    this.showArrows = false,
    this.onPageChanged,
  });

  @override
  State<StepCarousel> createState() => _StepCarouselState();
}

class _StepCarouselState extends State<StepCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStepContent(PostStep step) {
    switch (step.type) {
      case StepType.text:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            step.content['text'] as String? ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      case StepType.image:
        return Image.network(
          step.content['url'] as String? ?? '',
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
            );
          },
        );
      case StepType.video:
        // TODO: Implement video player
        return const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 48,
          ),
        );
      case StepType.audio:
        // TODO: Implement audio player
        return const Center(
          child: Icon(
            Icons.audiotrack,
            color: Colors.white,
            size: 48,
          ),
        );
      case StepType.quiz:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case StepType.code:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              step.content['code'] as String? ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        );
      case StepType.ar:
      case StepType.vr:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                step.type == StepType.ar ? Icons.view_in_ar : Icons.vrpano,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Launch ${step.type == StepType.ar ? 'AR' : 'VR'} Experience',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.steps.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            widget.onPageChanged?.call(index);
          },
          itemBuilder: (context, index) {
            final step = widget.steps[index];
            return _buildStepContent(step);
          },
        ),
        if (widget.showArrows && widget.steps.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _currentPage > 0
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox(width: 48),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _currentPage < widget.steps.length - 1
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox(width: 48),
            ),
          ),
        ],
      ],
    );
  }
}
