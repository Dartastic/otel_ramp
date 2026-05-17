// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_ramp_suppression.dart';

class RampResult {
  const RampResult({
    this.businessId,
    this.userId,
    this.cardId,
    this.spendProgramId,
    this.transactionId,
    this.amount,
    this.currency,
    this.merchantCategory,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? businessId;
  final String? userId;
  final String? cardId;
  final String? spendProgramId;
  final String? transactionId;
  final double? amount;
  final String? currency;
  final String? merchantCategory;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class RampCallResult<T> {
  const RampCallResult({required this.value, this.result});
  final T value;
  final RampResult? result;
}

Future<T> tracedRamp<T>({
  required String operation,
  required Future<RampCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (rampInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_ramp');
  final span = t.startSpan('ramp $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'ramp');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.businessId != null) {
        span.setStringAttribute('ramp.business.id', res.businessId!);
      }
      if (res.userId != null) {
        span.setStringAttribute('user.id', res.userId!);
      }
      if (res.cardId != null) {
        span.setStringAttribute('ramp.card.id', res.cardId!);
      }
      if (res.spendProgramId != null) {
        span.setStringAttribute('ramp.spend_program.id', res.spendProgramId!);
      }
      if (res.transactionId != null) {
        span.setStringAttribute('ramp.transaction.id', res.transactionId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('ramp.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('ramp.currency', res.currency!);
      }
      if (res.merchantCategory != null) {
        span.setStringAttribute(
          'ramp.merchant.category',
          res.merchantCategory!,
        );
      }
      if (res.status != null) {
        span.setStringAttribute('ramp.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('ramp.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'ramp.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
