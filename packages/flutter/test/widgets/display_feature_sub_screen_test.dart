// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisplayFeatureSubScreen', () {
    testWidgets('without Directionality or anchor', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            const DisplayFeature(
              bounds: Rect.fromLTRB(390, 0, 410, 600),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const DisplayFeatureSubScreen(
            child: SizedBox(
              key: childKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      );

      // With no Directionality or anchorpoint, the widget throws
      final String message = tester.takeException().toString();
      expect(message, contains('Directionality'));
    });

    testWidgets('with anchorPoint', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            const DisplayFeature(
              bounds: Rect.fromLTRB(390, 0, 410, 600),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const DisplayFeatureSubScreen(
            anchorPoint: Offset(600, 300),
            child: SizedBox(
              key: childKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      );

      // anchorPoint is in the middle of the right screen
      final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
      expect(renderBox.size.width, equals(390.0));
      expect(renderBox.size.height, equals(600.0));
      expect(renderBox.localToGlobal(Offset.zero), equals(const Offset(410,0)));
    });

    testWidgets('with infinity anchorpoint', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            const DisplayFeature(
              bounds: Rect.fromLTRB(390, 0, 410, 600),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const DisplayFeatureSubScreen(
            anchorPoint: Offset.infinite,
            child: SizedBox(
              key: childKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      );

      // anchorPoint is infinite, so the bottom-most & right-most screen is chosen
      final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
      expect(renderBox.size.width, equals(390.0));
      expect(renderBox.size.height, equals(600.0));
      expect(renderBox.localToGlobal(Offset.zero), equals(const Offset(410,0)));
    });

    testWidgets('with horizontal hinge and anchorPoint', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            const DisplayFeature(
              bounds: Rect.fromLTRB(0, 290, 800, 310),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const DisplayFeatureSubScreen(
            anchorPoint: Offset(1000, 1000),
            child: SizedBox(
              key: childKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      );

      final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
      expect(renderBox.size.width, equals(800.0));
      expect(renderBox.size.height, equals(290.0));
      expect(renderBox.localToGlobal(Offset.zero), equals(const Offset(0,310)));
    });

    testWidgets('with multiple display features and anchorPoint', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            const DisplayFeature(
              bounds: Rect.fromLTRB(0, 290, 800, 310),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
            const DisplayFeature(
              bounds: Rect.fromLTRB(390, 0, 410, 600),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const DisplayFeatureSubScreen(
            anchorPoint: Offset(1000, 1000),
            child: SizedBox(
              key: childKey,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      );

      final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
      expect(renderBox.size.width, equals(390.0));
      expect(renderBox.size.height, equals(290.0));
      expect(renderBox.localToGlobal(Offset.zero), equals(const Offset(410,310)));
    });

    testWidgets('with non-splitting display features and anchorPoint', (WidgetTester tester) async {
      const Key childKey = Key('childKey');
      final MediaQueryData mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).copyWith(
          displayFeatures: <DisplayFeature>[
            // Top notch
            const DisplayFeature(
              bounds: Rect.fromLTRB(100, 0, 700, 100),
              type: DisplayFeatureType.cutout,
              state: DisplayFeatureState.unknown,
            ),
            // Bottom notch
            const DisplayFeature(
              bounds: Rect.fromLTRB(100, 500, 700, 600),
              type: DisplayFeatureType.cutout,
              state: DisplayFeatureState.unknown,
            ),
          ]
      );

      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: DisplayFeatureSubScreen(
              child: SizedBox(
                key: childKey,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      );

      // The display features provided are not wide enough to produce sub-screens
      final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
      expect(renderBox.size.width, equals(800.0));
      expect(renderBox.size.height, equals(600.0));
      expect(renderBox.localToGlobal(Offset.zero), equals(Offset.zero));
    });
  });
}
