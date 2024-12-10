import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepDots extends StatefulWidget {
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

  @override
  State<StepDots> createState() => _StepDotsState();
}

class _StepDotsState extends State<StepDots> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: -8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StepDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      if (_isFirstOrLastStep) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  bool get _isFirstOrLastStep => widget.currentStep == 0 || widget.currentStep == widget.steps.length - 1;

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isFirstOrLastStep && details.delta.dy > 0) {
      widget.onHeaderExpandChanged(true);
    }
  }

  void _handleDotTap(int index) {
    if (index == 0 || index == widget.steps.length - 1) {
      widget.onHeaderExpandChanged(true);
    } else {
      widget.onTransformToMiniatures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          transform: Matrix4.translationValues(0, _offsetAnimation.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.steps.length,
              (index) => GestureDetector(
                onTap: () => _handleDotTap(index),
                onVerticalDragUpdate: _isFirstOrLastStep ? _handleVerticalDragUpdate : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44.0 * _sizeAnimation.value,
                  height: 44.0,
                  alignment: Alignment.center,
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == widget.currentStep
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
