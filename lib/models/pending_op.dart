// lib/models/pending_op.dart
import 'dart:convert';

enum PendingKind { create, toggle, update, delete }

String pendingKindToString(PendingKind k) {
  switch (k) {
    case PendingKind.create:
      return 'create';
    case PendingKind.toggle:
      return 'toggle';
    case PendingKind.update:
      return 'update';
    case PendingKind.delete:
      return 'delete';
  }
}

PendingKind pendingKindFromString(String s) {
  switch (s) {
    case 'create':
      return PendingKind.create;
    case 'toggle':
      return PendingKind.toggle;
    case 'update':
      return PendingKind.update;
    case 'delete':
      return PendingKind.delete;
    default:
      throw ArgumentError('Unknown PendingKind: $s');
  }
}

class PendingOp {
  final String opId; // unique id for this operation (e.g. uuid)
  final PendingKind kind; // create|toggle|update|delete
  final String id; // task id (temp id until remapped after create)
  final Map<String, dynamic>? payload; // body/patch if needed
  final DateTime ts; // timestamp when queued
  final int attempts; // retry attempts so far

  PendingOp({
    required this.opId,
    required this.kind,
    required this.id,
    required this.payload,
    required this.ts,
    this.attempts = 0,
  });

  PendingOp copyWith({
    String? opId,
    PendingKind? kind,
    String? id,
    Map<String, dynamic>? payload,
    DateTime? ts,
    int? attempts,
  }) {
    return PendingOp(
      opId: opId ?? this.opId,
      kind: kind ?? this.kind,
      id: id ?? this.id,
      payload: payload ?? this.payload,
      ts: ts ?? this.ts,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() => {
    'opId': opId,
    'kind': pendingKindToString(kind),
    'id': id,
    'payload': payload,
    'ts': ts.toIso8601String(),
    'attempts': attempts,
  };

  static PendingOp fromJson(Map<String, dynamic> j) => PendingOp(
    opId: j['opId'] as String,
    kind: pendingKindFromString(j['kind'] as String),
    id: j['id'] as String,
    payload: (j['payload'] as Map?)?.cast<String, dynamic>(),
    ts: DateTime.parse(j['ts'] as String),
    attempts: (j['attempts'] as num?)?.toInt() ?? 0,
  );

  // Helpers to encode/decode lists
  static String encodeList(List<PendingOp> ops) =>
      jsonEncode(ops.map((e) => e.toJson()).toList());

  static List<PendingOp> decodeList(String s) {
    final list = (jsonDecode(s) as List).cast<Map>();
    return list.map((m) => PendingOp.fromJson(m.cast())).toList();
  }
}
