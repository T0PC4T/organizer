import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const NORMAL_SCROLL_ANIMATION_LENGTH_MS = 150;
const SCROLL_SPEED = 165;

class SmoothListView extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  const SmoothListView({super.key, required this.children, this.padding});

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  double desiredPosition = 0;
  late ScrollController controller;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          desiredPosition += pointerSignal.scrollDelta.dy;
          desiredPosition =
              desiredPosition.clamp(0, controller.position.maxScrollExtent);

          if (pointerSignal.scrollDelta.dy.abs() < 50) {
            return controller.jumpTo(
              desiredPosition,
            );
          }

          controller.animateTo(
            desiredPosition,
            duration:
                const Duration(milliseconds: NORMAL_SCROLL_ANIMATION_LENGTH_MS),
            curve: Curves.easeOut,
          );
        }
      },
      child: ListView(
        padding: widget.padding,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: widget.children,
      ),
    );
  }
}
