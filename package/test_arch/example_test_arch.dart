// test_arch/example_arch_test.dart
//
// Architecture rule: UI layer must not access data layer directly.
//
// Run with:
//   dart test test_arch/example_arch_test.dart
//   dartunit analyze

import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArch('UI layer must not access the data layer directly',
    (arch) {
  final ui = arch.classes(folder: 'lib/ui');
  expect(ui, doesNotDependOn('lib/data'));
});
