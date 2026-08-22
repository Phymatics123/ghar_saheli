import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/ui/widgets/fill_viewport_scroll.dart';

/// Layout tests for the one idiom in this app that fails catastrophically
/// rather than visibly.
///
/// A Spacer inside a plain SingleChildScrollView throws during layout, and a
/// throw during layout leaves the entire frame unlaid-out — the app opens to a
/// white screen with no clue on it. It is worth a test precisely because the
/// failure gives the user nothing to report back.
void main() {
  Widget wrap(Widget child, {EdgeInsets? padding}) => Directionality(
        textDirection: TextDirection.ltr,
        child: FillViewportScroll(padding: padding, child: child),
      );

  group('FillViewportScroll', () {
    testWidgets('lays out a Column containing Spacers', (WidgetTester t) async {
      await t.pumpWidget(
        wrap(
          Column(
            children: const <Widget>[
              Spacer(),
              Text('middle'),
              Spacer(),
              Text('footnote'),
            ],
          ),
        ),
      );

      // The assertion that matters: no exception. Everything else about this
      // screen is unreachable if layout threw.
      expect(t.takeException(), isNull);
      expect(find.text('footnote'), findsOneWidget);
    });

    testWidgets('stretches short content to fill the viewport', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        wrap(
          Column(
            children: const <Widget>[
              Text('top'),
              Spacer(),
              Text('bottom'),
            ],
          ),
        ),
      );

      // The Spacer only earns its keep if the column is taller than its
      // contents — otherwise the footnote rides up under the button.
      final double viewport =
          t.view.physicalSize.height / t.view.devicePixelRatio;
      expect(t.getSize(find.byType(Column)).height, viewport);
      expect(t.getBottomLeft(find.text('bottom')).dy, closeTo(viewport, 1));
    });

    testWidgets('scrolls instead of overflowing when content is taller', (
      WidgetTester t,
    ) async {
      t.view.physicalSize = const Size(400, 300);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      await t.pumpWidget(
        wrap(
          Column(
            children: const <Widget>[
              Spacer(),
              SizedBox(height: 900, child: Text('tall')),
              Spacer(),
            ],
          ),
        ),
      );

      // No overflow stripe, and the content is reachable by scrolling. This is
      // the keyboard-is-open case on a short phone.
      expect(t.takeException(), isNull);
      await t.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await t.pump();
      expect(t.takeException(), isNull);
    });

    testWidgets('takes its padding off the minimum height', (
      WidgetTester t,
    ) async {
      // Otherwise every screen using this is permanently scrollable by exactly
      // the height of its own padding, which reads as a layout bug.
      await t.pumpWidget(
        wrap(
          Column(children: const <Widget>[Spacer(), Text('x')]),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
      );

      final double viewport =
          t.view.physicalSize.height / t.view.devicePixelRatio;
      expect(t.getSize(find.byType(Column)).height, viewport - 40);
    });

    testWidgets('shrink-wraps rather than throwing when nested unbounded', (
      WidgetTester t,
    ) async {
      // Guards the guard: asking for an infinite minimum height would raise
      // the very error this widget exists to prevent.
      await t.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            child: FillViewportScroll(
              child: Column(children: const <Widget>[Text('nested')]),
            ),
          ),
        ),
      );

      expect(t.takeException(), isNull);
      expect(find.text('nested'), findsOneWidget);
    });
  });
}
