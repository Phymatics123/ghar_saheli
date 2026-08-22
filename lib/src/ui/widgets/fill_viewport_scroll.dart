import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A scroll view whose child is at least as tall as the space it was given.
///
/// This exists as its own widget because the obvious spelling of it is wrong,
/// and wrong in a way that does not fail gracefully. A [SingleChildScrollView]
/// hands its child an *unbounded* height. A [Spacer] or [Expanded] inside an
/// unbounded [Column] is a contradiction — it asks to fill space that has no
/// size — so layout throws, and a throw during layout means nothing on the
/// screen is laid out at all. The user gets a white screen, not a misplaced
/// widget, which makes it a disproportionately expensive mistake to repeat.
///
/// The three pieces each do one job. [LayoutBuilder] reads the height actually
/// available, rather than guessing at it from [MediaQuery] and subtracting the
/// keyboard and the notch by hand. [IntrinsicHeight] measures the child at its
/// natural height first, so there is something concrete to stretch. The
/// minimum constraint then stretches it to fill the viewport when there is
/// room to.
///
/// The result is a screen that pushes a footnote to the bottom on a tall
/// phone, and scrolls out of the keyboard's way on a short one, without
/// needing two layouts.
class FillViewportScroll extends StatelessWidget {
  const FillViewportScroll({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Padding eats into the room the child gets, so it has to come off the
        // minimum too. Without this the child is always a little taller than
        // the viewport and every screen scrolls slightly for no reason.
        final EdgeInsets inset =
            (padding ?? EdgeInsets.zero).resolve(Directionality.of(context));

        // Nested inside another scrollable there is no finite height to fill,
        // and asking for an infinite minimum would throw the very error this
        // widget exists to prevent. Shrink-wrap instead.
        final double available = constraints.maxHeight.isFinite
            ? math.max(0, constraints.maxHeight - inset.vertical)
            : 0;

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: available),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
