// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_ramp/otel_ramp.dart';
import 'package:test/test.dart';

void main() {
  group('otel_ramp', () {
    test('suppression toggles in zone', () async {
      expect(rampInstrumentationSuppressed(), isFalse);
      await runWithoutRampInstrumentationAsync(() async {
        expect(rampInstrumentationSuppressed(), isTrue);
      });
      expect(rampInstrumentationSuppressed(), isFalse);
    });

    test('RampResult fields default null', () {
      const r = RampResult();
      expect(r.statusCode, isNull);
    });
  });
}
