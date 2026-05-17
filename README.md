# otel_ramp

Dartastic OpenTelemetry bridge for Ramp (corporate cards + spend mgmt).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_ramp/otel_ramp.dart';

await tracedRamp<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return RampCallResult(value: r, result: RampResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutRampInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
