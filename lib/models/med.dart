import 'package:flutter/material.dart';

class Medication {
  final String name;
  final String dosage;
  final TimeOfDay time;
  final String? notes;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    this.notes,
  });

  @override
  String toString() => '$name — $dosage at ${time.format(const _FakeContext())}';
}

// A tiny helper so that toString has a fallback for formatting time in
// environments where BuildContext isn't available. It uses 24-hour format.
class _FakeContext implements BuildContext {
  const _FakeContext();
  // All members below are unused; implement minimal stubs to satisfy type.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
