/// dartunit — Architecture testing tool for Dart and Flutter projects.
///
/// This library exposes all public APIs needed to:
/// - Run the CLI (`DartunitCli`)
/// - Implement custom rules (`CustomArchitectureRule`)
/// - Build rules programmatically (`ArchitectureRule`, `RuleEngine`)
/// - Use selectors and predicates

library dartunit;

// CLI
export 'cli/dartunit_cli.dart';
export 'cli/commands/init_command.dart';
export 'cli/commands/analyze_command.dart';
export 'cli/commands/generate_command.dart';
export 'cli/commands/log_command.dart';

// Templates
export 'core/enums/arch_template.dart';
export 'core/enums/arch_template_extension.dart';

// Core — Rule
export 'core/entities/rule.dart';
export 'core/entities/violation.dart';
export 'core/enums/rule_severity.dart';

// Core — Selectors
export 'core/entities/selector.dart' show Selector;
export 'core/entities/subject.dart' show Subject;
export 'core/selector/class_selector.dart';
export 'core/selector/file_selector.dart';
export 'core/selector/layer_selector.dart';

// Core — Predicates
export 'core/entities/predicate.dart';
export 'core/predicates/depend_on_folder_predicate.dart';
export 'core/predicates/depend_on_package_predicate.dart';
export 'core/predicates/only_depend_on_folders_predicate.dart';
export 'core/predicates/max_imports_predicate.dart';
export 'core/predicates/has_circular_dependency_predicate.dart';
export 'core/predicates/name_ends_with_predicate.dart';
export 'core/predicates/name_starts_with_predicate.dart';
export 'core/predicates/name_contains_predicate.dart';
export 'core/predicates/name_matches_pattern_predicate.dart';
export 'core/predicates/annotation_predicate.dart';
export 'core/predicates/not_annotated_with_predicate.dart';
export 'core/predicates/extends_predicate.dart';
export 'core/predicates/implements_predicate.dart';
export 'core/predicates/uses_mixin_predicate.dart';
export 'core/predicates/is_abstract_predicate.dart';
export 'core/predicates/is_enum_predicate.dart';
export 'core/predicates/is_mixin_predicate.dart';
export 'core/predicates/is_extension_predicate.dart';
export 'core/predicates/is_concrete_class_predicate.dart';
export 'core/predicates/max_methods_predicate.dart';
export 'core/predicates/max_fields_predicate.dart';
export 'core/predicates/min_methods_predicate.dart';
export 'core/predicates/min_fields_predicate.dart';
export 'core/predicates/has_all_final_fields_predicate.dart';
export 'core/predicates/has_no_public_fields_predicate.dart';
export 'core/predicates/has_method_predicate.dart';
export 'core/predicates/has_no_public_methods_predicate.dart';
export 'core/predicates/content_predicate.dart';
export 'core/predicates/composite/and_predicate.dart';
export 'core/predicates/composite/or_predicate.dart';
export 'core/predicates/composite/not_predicate.dart';

// Analyzer
export 'analyzer/project_analyzer.dart';
export 'analyzer/context/analysis_context.dart';
export 'analyzer/models/analyzed_class.dart';
export 'analyzer/models/analyzed_file.dart';
export 'analyzer/models/analyzed_method.dart';
export 'analyzer/models/analyzed_field.dart';
export 'analyzer/graph/dependency_graph.dart';

// Engine
export 'engine/rule_engine.dart';
export 'engine/rule_executor.dart';
export 'engine/custom_rule_loader.dart';

// Runner
export 'runner/arch_flutter_runner.dart' show testArch, testArchGroup;

// YAML
export 'yaml/yaml_rule_parser.dart';

// Reporter
export 'reporter/console_reporter.dart';
