// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'ramp')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.businessId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.business.id', res.businessId!)]));
      }
      if (res.userId != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('user.id', res.userId!)]));
      }
      if (res.cardId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.card.id', res.cardId!)]));
      }
      if (res.spendProgramId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('ramp.spend_program.id', res.spendProgramId!)
        ]));
      }
      if (res.transactionId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.transaction.id', res.transactionId!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('ramp.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.currency', res.currency!)]));
      }
      if (res.merchantCategory != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'ramp.merchant.category',
            res.merchantCategory!,
          )
        ]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('ramp.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'ramp.error',
          )
        ]));
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
