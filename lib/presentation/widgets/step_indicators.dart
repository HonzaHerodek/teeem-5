import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepDots extends StatelessWidget {
  final List<PostStep> steps;
  final int currentStep;
  final Animation<double> animation;
  static const double _dotSize = 8.0;

  const StepDots({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          steps.length,
          (index) => Container(
            width: _dotSize,
            height: _dotSize,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentStep
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}

class StepMiniatures extends StatelessWidget {
  final List<PostStep> steps;
  final int currentStep;
  final Animation<double> animation;
  static const double _miniatureSize = 60.0;

  const StepMiniatures({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.animation,
  });

  Widget _buildMiniature(PostStep step, int index) {
    return Container(
      width: _miniatureSize,
      height: _miniatureSize,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.3),
        border: Border.all(
          color: index == currentStep 
              ? Colors.white 
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                color: index == currentStep 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (step.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  step.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: index == currentStep 
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: SizedBox(
          height: _miniatureSize,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildMiniature(
              steps[index],
              index,
            ),
          ),
        ),
      ),
    );
  }
}
