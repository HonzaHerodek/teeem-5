import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepDots extends StatelessWidget {
  final List<PostStep> steps;
  final int currentStep;
  final Function(bool) onHeaderExpandChanged;
  final VoidCallback onTransformToMiniatures;

  const StepDots({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onHeaderExpandChanged,
    required this.onTransformToMiniatures,
  }) : super(key: key);

  bool get _isFirstOrLastStep => currentStep == 0 || currentStep == steps.length - 1;

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isFirstOrLastStep && details.delta.dy > 0) {
      onHeaderExpandChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If on first or last step, entire area expands header
    if (_isFirstOrLastStep) {
      return GestureDetector(
        onTap: () => onHeaderExpandChanged(true),
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              steps.length,
              (index) => Container(
                width: 44.0,
                height: 44.0,
                alignment: Alignment.center,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentStep
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Normal behavior for middle steps
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          steps.length,
          (index) => GestureDetector(
            onTap: () {
              if (index == 0 || index == steps.length - 1) {
                onHeaderExpandChanged(true);
              } else {
                onTransformToMiniatures();
              }
            },
            child: Container(
              width: 44.0,
              height: 44.0,
              alignment: Alignment.center,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentStep
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
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
  final Function(bool) onHeaderExpandChanged;
  final VoidCallback? onTransformToDots;

  const StepMiniatures({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onHeaderExpandChanged,
    this.onTransformToDots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          steps.length,
          (index) => GestureDetector(
            onTap: () {
              if (index == 0 || index == steps.length - 1) {
                onHeaderExpandChanged(false);
              } else if (onTransformToDots != null) {
                onTransformToDots!();
              }
            },
            child: Container(
              width: 68.0,
              height: 68.0,
              alignment: Alignment.center,
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: index == currentStep 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
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
                      if (steps[index].title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            steps[index].title,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
