import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'dart:ui';

void showCustomOverlayBar(BuildContext context, String message,
    {Duration duration = const Duration(milliseconds: 3000),
    Color textColor = Colors.white}) {
  final overlay = Overlay.of(context);

  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return _AnimatedOverlayBar(
        message: message,
        duration: duration,
        textColor: textColor,
        onClose: () => overlayEntry?.remove(),
      );
    },
  );

  overlay.insert(overlayEntry);
}

void showSuccessBar(BuildContext context) {
  showCustomOverlayBar(context, 'تمت العملية بنجاح',
      duration: Duration(milliseconds: 400), textColor: Colors.green);
}

class _AnimatedOverlayBar extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onClose;
  final Color textColor;

  const _AnimatedOverlayBar({
    Key? key,
    required this.message,
    required this.duration,
    required this.onClose,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  State<_AnimatedOverlayBar> createState() => _AnimatedOverlayBarState();
}

class _AnimatedOverlayBarState extends State<_AnimatedOverlayBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Non-linear curve
    ));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.6;

    return Positioned(
      bottom: 32,
      left: (screenWidth - barWidth) / 2,
      width: barWidth,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: m.Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(m.Icons.info_outline, color: Colors.white),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 16,
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
