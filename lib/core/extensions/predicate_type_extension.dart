import 'package:yaml/yaml.dart';
import '../enums/predicate_type.dart';
import '../entities/predicate.dart';
import '../predicates/depend_on_folder_predicate.dart';
import '../predicates/depend_on_package_predicate.dart';
import '../predicates/only_depend_on_folders_predicate.dart';
import '../predicates/max_imports_predicate.dart';
import '../predicates/has_circular_dependency_predicate.dart';
import '../predicates/name_ends_with_predicate.dart';
import '../predicates/name_starts_with_predicate.dart';
import '../predicates/name_contains_predicate.dart';
import '../predicates/name_matches_pattern_predicate.dart';
import '../predicates/annotation_predicate.dart';
import '../predicates/not_annotated_with_predicate.dart';
import '../predicates/extends_predicate.dart';
import '../predicates/implements_predicate.dart';
import '../predicates/uses_mixin_predicate.dart';
import '../predicates/is_abstract_predicate.dart';
import '../predicates/is_enum_predicate.dart';
import '../predicates/is_mixin_predicate.dart';
import '../predicates/is_extension_predicate.dart';
import '../predicates/is_concrete_class_predicate.dart';
import '../predicates/max_methods_predicate.dart';
import '../predicates/max_fields_predicate.dart';
import '../predicates/min_methods_predicate.dart';
import '../predicates/min_fields_predicate.dart';
import '../predicates/has_all_final_fields_predicate.dart';
import '../predicates/has_no_public_fields_predicate.dart';
import '../predicates/has_method_predicate.dart';
import '../predicates/has_no_public_methods_predicate.dart';
import '../predicates/content_predicate.dart';

extension PredicateTypeBuilder on PredicateType {

  /// Constructs the [Predicate] corresponding to this type.
  ///
  /// [value] is the scalar `value:` field from the YAML node.
  /// [raw] is the full YAML map for types that need a list (e.g. [onlyDependOnFolders]).
  Predicate build(dynamic value, YamlMap raw) => switch (this) {
  // Dependency
    PredicateType.dependOnFolder =>
        DependOnFolderPredicate(value as String),
    PredicateType.dependOnPackage =>
        DependOnPackagePredicate(value as String),
    PredicateType.onlyDependOnFolders => OnlyDependOnFoldersPredicate(
      (raw['value'] as YamlList).map((e) => e as String).toList(),
    ),
    PredicateType.maxImports => MaxImportsPredicate(value as int),
    PredicateType.hasCircularDependency =>
    const HasCircularDependencyPredicate(),

  // Naming
    PredicateType.nameEndsWith => NameEndsWithPredicate(value as String),
    PredicateType.nameStartsWith =>
        NameStartsWithPredicate(value as String),
    PredicateType.nameMatchesPattern =>
        NameMatchesPatternPredicate(value as String),
    PredicateType.nameContains => NameContainsPredicate(value as String),

  // Annotations
    PredicateType.annotatedWith =>
        AnnotatedWithPredicate(value as String),
    PredicateType.notAnnotatedWith =>
        NotAnnotatedWithPredicate(value as String),

  // Inheritance
    PredicateType.extendsType => ExtendsPredicate(value as String),
    PredicateType.implementsType => ImplementsPredicate(value as String),
    PredicateType.usesMixin => UsesMixinPredicate(value as String),

  // Structural kind
    PredicateType.isAbstract => const IsAbstractPredicate(),
    PredicateType.isEnum => const IsEnumPredicate(),
    PredicateType.isMixin => const IsMixinPredicate(),
    PredicateType.isExtension => const IsExtensionPredicate(),
    PredicateType.isConcrete => const IsConcreteClassPredicate(),

// Metrics
    PredicateType.maxMethods => MaxMethodsPredicate(value as int),
    PredicateType.maxFields => MaxFieldsPredicate(value as int),
    PredicateType.minMethods => MinMethodsPredicate(value as int),
    PredicateType.minFields => MinFieldsPredicate(value as int),

  // Fields
    PredicateType.hasAllFinalFields => const HasAllFinalFieldsPredicate(),
    PredicateType.hasNoPublicFields => const HasNoPublicFieldsPredicate(),

  // Methods
    PredicateType.hasMethod => HasMethodPredicate(value as String),
    PredicateType.hasNoPublicMethods =>
    const HasNoPublicMethodsPredicate(),

  // File content
    PredicateType.fileContentMatches =>
        FileContentMatchesPredicate(value as String),
  };
}