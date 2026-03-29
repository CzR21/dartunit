import 'dart:io';
import 'package:yaml/yaml.dart';
import '../core/entities/rule.dart';
import '../core/enums/rule_severity.dart';
import '../core/entities/predicate.dart';
import '../core/predicates/composite/and_predicate.dart';
import '../core/predicates/composite/or_predicate.dart';
import '../core/predicates/composite/not_predicate.dart';
import '../core/entities/selector.dart' show Selector;
import '../core/enums/predicate_type.dart';
import '../core/enums/selector_type.dart';
import '../core/extensions/predicate_type_extension.dart';
import '../core/extensions/selector_type_extension.dart';
import '../presets/preset_expander.dart';

/// Parses a `dartunit.yaml` file into a list of [Rule]s.
class YamlRuleParser {
  /// Loads and parses the YAML config at [configPath].
  ///
  /// Throws [StateError] if the file does not exist.
  /// Returns an empty list if the file contains no `rules` key.
  List<Rule> parse(String configPath) {
    final file = File(configPath);
    if (!file.existsSync()) {
      throw StateError('Configuration file not found: $configPath');
    }

    final doc = loadYaml(file.readAsStringSync()) as YamlMap?;
    if (doc == null) return [];

    final rules = doc.containsKey('rules')
        ? (doc['rules'] as YamlList)
            .map((r) => _parseRule(r as YamlMap))
            .whereType<Rule>()
            .toList()
        : <Rule>[];

    final presetRules = doc.containsKey('presets')
        ? PresetExpander().expand(doc['presets'] as YamlList)
        : <Rule>[];

    return [...rules, ...presetRules];
  }

  Rule? _parseRule(YamlMap raw) {
    final description = raw['description'] as String? ?? '';
    final severity =
        RuleSeverity.fromString(raw['severity'] as String? ?? 'error');
    final exceptions = _parseStringList(raw['exceptions']);

    final selectorRaw = raw['selector'] as YamlMap?;
    final predicateRaw = raw['predicate'] as YamlMap?;

    if (selectorRaw == null || predicateRaw == null) {
      stderr.writeln(
          'Warning: Rule "$description" is missing selector or predicate — skipped.');
      return null;
    }

    final selector = _parseSelector(selectorRaw);
    final predicate = _parsePredicate(predicateRaw);

    if (selector == null || predicate == null) {
      stderr.writeln(
          'Warning: Rule "$description" has an invalid selector or predicate — skipped.');
      return null;
    }

    return Rule(
      description: description,
      severity: severity,
      selector: selector,
      predicate: predicate,
      exceptions: exceptions,
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is String) return [value];
    return (value as YamlList).map((e) => e as String).toList();
  }

  Selector? _parseSelector(YamlMap raw) {
    final typeStr = raw['type'] as String? ?? 'class';
    final selectorType = SelectorType.fromString(typeStr);

    if (selectorType == null) {
      stderr.writeln('Unknown selector type: $typeStr');
      return null;
    }

    return selectorType.build(raw['where'] as YamlMap?);
  }

  Predicate? _parsePredicate(YamlMap raw) {
    // Composite: not (recursive)
    if (raw.containsKey('not')) {
      final inner = _parsePredicate(raw['not'] as YamlMap);
      return inner == null ? null : NotPredicate(inner);
    }

    // Composite: and (recursive list)
    if (raw.containsKey('and')) {
      return AndPredicate((raw['and'] as YamlList)
          .map((p) => _parsePredicate(p as YamlMap))
          .whereType<Predicate>()
          .toList());
    }

    // Composite: or (recursive list)
    if (raw.containsKey('or')) {
      return OrPredicate((raw['or'] as YamlList)
          .map((p) => _parsePredicate(p as YamlMap))
          .whereType<Predicate>()
          .toList());
    }

    // Atomic predicate
    final typeStr = raw['type'] as String?;
    final predicateType = PredicateType.fromString(typeStr);

    if (predicateType == null) {
      stderr.writeln('Unknown predicate type: $typeStr');
      return null;
    }

    return predicateType.build(raw['value'], raw);
  }
}

