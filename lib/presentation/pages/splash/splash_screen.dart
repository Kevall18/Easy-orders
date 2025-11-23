import 'package:easy_orders/core/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart'; // <-- 1. IMPORT GET

class LoadingSplashScreen extends StatefulWidget {
  const LoadingSplashScreen({super.key});

  @override
  LoadingSplashScreenState createState() => LoadingSplashScreenState();
}

class LoadingSplashScreenState extends State<LoadingSplashScreen>
    with TickerProviderStateMixin {
  static const List<String> _letters = ['G', 'N', 'I', 'D', 'A', 'O', 'L'];
  final List<AnimationController> _controllers = [];

  late final TweenSequence<double> _leftTween;
  late final TweenSequence<double> _opacityTween;
  late final TweenSequence<double> _rotationTween;

  static const int _animationDurationMs = 2000;
  static const int _staggerDelayMs = 200;

  // --- 2. SET NAVIGATION DELAY ---
  // You can change this value
  static const int _navigationDelayMs = 3000; // 4 seconds

  @override
  void initState() {
    super.initState();

    _leftTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.41), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.41, end: 0.59), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.59, end: 1.0), weight: 35),
    ]);

    _opacityTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]);

    _rotationTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: math.pi, end: 0.0), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -math.pi), weight: 35),
    ]);

    for (int i = 0; i < _letters.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: _animationDurationMs),
        vsync: this,
      );
      _controllers.add(controller);

      Future.delayed(Duration(milliseconds: i * _staggerDelayMs), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }

    // --- 3. ADD NAVIGATION LOGIC ---
    Future.delayed(const Duration(milliseconds: _navigationDelayMs), () {
      // Check if the widget is still in the widget tree (i.e., not disposed)
      // before trying to navigate.
      if (mounted) {
        final authController = Get.find<AuthController>();

        // Check its state and navigate
        if (authController.isLoggedIn) {
          // User is logged in
          Get.offAllNamed("/analytics");
        } else {
          // User is not logged in
          Get.offAllNamed("/login");
        }
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors from the theme provided by the context
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color letterColor = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 36,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: List.generate(_letters.length, (index) {
                  final controller = _controllers[index];

                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final double leftFraction = _leftTween.evaluate(controller);
                      final double opacity = _opacityTween.evaluate(controller);
                      final double rotation = _rotationTween.evaluate(controller);

                      return Positioned(
                        top: 0,
                        left: leftFraction * constraints.maxWidth,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 20,
                              height: 36,
                              alignment: Alignment.center,
                              child: Text(
                                _letters[index],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: letterColor,
                                  fontFamily: 'Verdana',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}