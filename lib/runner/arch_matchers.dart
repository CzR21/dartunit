import 'package:test/test.dart';
import '../core/entities/arch_matcher.dart';
import '../core/predicates/annotation_predicate.dart';
import '../core/predicates/composite/not_predicate.dart';
import '../core/predicates/content_predicate.dart';
import '../core/predicates/depend_on_folder_predicate.dart';
import '../core/predicates/depend_on_package_predicate.dart';
import '../core/predicates/extends_predicate.dart';
import '../core/predicates/has_all_final_fields_predicate.dart';
import '../core/predicates/has_circular_dependency_predicate.dart';
import '../core/predicates/has_method_predicate.dart';
import '../core/predicates/has_no_public_fields_predicate.dart';
import '../core/predicates/has_no_public_methods_predicate.dart';
import '../core/predicates/implements_predicate.dart';
import '../core/predicates/is_abstract_predicate.dart';
import '../core/predicates/is_concrete_class_predicate.dart';
import '../core/predicates/is_enum_predicate.dart';
import '../core/predicates/is_extension_predicate.dart';
import '../core/predicates/is_mixin_predicate.dart';
import '../core/predicates/max_fields_predicate.dart';
import '../core/predicates/max_imports_predicate.dart';
import '../core/predicates/max_methods_predicate.dart';
import '../core/predicates/min_fields_predicate.dart';
import '../core/predicates/min_methods_predicate.dart';
import '../core/predicates/name_contains_predicate.dart';
import '../core/predicates/name_ends_with_predicate.dart';
import '../core/predicates/name_matches_pattern_predicate.dart';
import '../core/predicates/name_starts_with_predicate.dart';
import '../core/predicates/not_annotated_with_predicate.dart';
import '../core/predicates/only_depend_on_folders_predicate.dart';
import '../core/predicates/uses_mixin_predicate.dart';

/// Expects that selected classes do NOT import from [folder].
Matcher doesNotDependOn(String folder) => ArchMatcher(
      NotPredicate(DependOnFolderPredicate(folder)),
      'must not depend on "$folder"',
    );

/// Expects that selected classes import from [folder].
Matcher dependsOn(String folder) => ArchMatcher(
      DependOnFolderPredicate(folder),
      'must depend on "$folder"',
    );

/// Expects that selected classes do NOT transitively depend on [folder].
Matcher doesNotDependOnTransitive(String folder) => ArchMatcher(
      NotPredicate(DependOnFolderPredicate(folder, transitive: true)),
      'must not transitively depend on "$folder"',
    );

/// Expects that selected classes transitively depend on [folder].
Matcher dependsOnTransitive(String folder) => ArchMatcher(
      DependOnFolderPredicate(folder, transitive: true),
      'must transitively depend on "$folder"',
    );

/// Expects that selected classes do NOT import from [package].
Matcher doesNotDependOnPackage(String package) => ArchMatcher(
      NotPredicate(DependOnPackagePredicate(package)),
      'must not depend on package "$package"',
    );

/// Expects that selected classes import from [package].
Matcher dependsOnPackage(String package) => ArchMatcher(
      DependOnPackagePredicate(package),
      'must depend on package "$package"',
    );

/// Expects that selected classes only import from the given [folders].
Matcher onlyDependsOnFolders(List<String> folders) => ArchMatcher(
      OnlyDependOnFoldersPredicate(folders),
      'must only depend on: ${folders.join(', ')}',
    );

/// Expects that selected classes have at most [max] imports.
Matcher hasMaxImports(int max) => ArchMatcher(
      MaxImportsPredicate(max),
      'must have at most $max imports',
    );

/// Expects that selected files are involved in a circular dependency.
Matcher hasCircularDependency() => ArchMatcher(
      HasCircularDependencyPredicate(),
      'must have a circular dependency',
    );

/// Expects that selected files are NOT involved in a circular dependency.
Matcher hasNoCircularDependency() => ArchMatcher(
      NotPredicate(HasCircularDependencyPredicate()),
      'must not have circular dependencies',
    );

/// Expects that selected elements have names ending with [suffix].
Matcher nameEndsWith(String suffix) => ArchMatcher(
      NameEndsWithPredicate(suffix),
      'name must end with "$suffix"',
    );

/// Expects that selected elements have names starting with [prefix].
Matcher nameStartsWith(String prefix) => ArchMatcher(
      NameStartsWithPredicate(prefix),
      'name must start with "$prefix"',
    );

/// Expects that selected elements have names containing [substring].
Matcher nameContains(String substring) => ArchMatcher(
      NameContainsPredicate(substring),
      'name must contain "$substring"',
    );

/// Expects that selected elements have names matching the regex [pattern].
Matcher nameMatchesPattern(String pattern) => ArchMatcher(
      NameMatchesPatternPredicate(pattern),
      'name must match pattern "$pattern"',
    );

/// Expects that selected classes have the annotation [name].
Matcher hasAnnotation(String name) => ArchMatcher(
      AnnotatedWithPredicate(name),
      'must be annotated with @$name',
    );

/// Expects that selected classes do NOT have the annotation [name].
Matcher doesNotHaveAnnotation(String name) => ArchMatcher(
      NotAnnotatedWithPredicate(name),
      'must not be annotated with @$name',
    );

/// Expects that selected classes extend [className].
Matcher extendsClass(String className) => ArchMatcher(
      ExtendsPredicate(className),
      'must extend $className',
    );

/// Expects that selected classes implement [interfaceName].
Matcher implementsInterface(String interfaceName) => ArchMatcher(
      ImplementsPredicate(interfaceName),
      'must implement $interfaceName',
    );

/// Expects that selected classes use the mixin [mixinName].
Matcher usesMixin(String mixinName) => ArchMatcher(
      UsesMixinPredicate(mixinName),
      'must use mixin $mixinName',
    );

/// Expects that selected classes are abstract.
Matcher isAbstractClass() =>
    ArchMatcher(IsAbstractPredicate(), 'must be abstract');

/// Expects that selected classes are concrete (not abstract).
Matcher isConcreteClass() =>
    ArchMatcher(IsConcreteClassPredicate(), 'must be concrete');

/// Expects that selected types are enums.
Matcher isEnumType() => ArchMatcher(IsEnumPredicate(), 'must be an enum');

/// Expects that selected types are mixins.
Matcher isMixinType() => ArchMatcher(IsMixinPredicate(), 'must be a mixin');

/// Expects that selected types are extensions.
Matcher isExtensionType() =>
    ArchMatcher(IsExtensionPredicate(), 'must be an extension');

/// Expects that selected classes have at most [max] methods.
Matcher hasMaxMethods(int max) => ArchMatcher(
      MaxMethodsPredicate(max),
      'must have at most $max methods',
    );

/// Expects that selected classes have at least [min] methods.
Matcher hasMinMethods(int min) => ArchMatcher(
      MinMethodsPredicate(min),
      'must have at least $min methods',
    );

/// Expects that selected classes have at most [max] fields.
Matcher hasMaxFields(int max) => ArchMatcher(
      MaxFieldsPredicate(max),
      'must have at most $max fields',
    );

/// Expects that selected classes have at least [min] fields.
Matcher hasMinFields(int min) => ArchMatcher(
      MinFieldsPredicate(min),
      'must have at least $min fields',
    );

/// Expects that all instance fields of selected classes are final.
Matcher hasAllFinalFields() => ArchMatcher(
      HasAllFinalFieldsPredicate(),
      'must have all-final fields',
    );

/// Expects that selected classes expose no public mutable fields.
Matcher hasNoPublicFields() => ArchMatcher(
      HasNoPublicFieldsPredicate(),
      'must have no public fields',
    );

/// Expects that selected classes have a method named [methodName].
Matcher hasMethod(String methodName) => ArchMatcher(
      HasMethodPredicate(methodName),
      'must have a method named "$methodName"',
    );

/// Expects that selected classes expose no public methods.
Matcher hasNoPublicMethods() => ArchMatcher(
      HasNoPublicMethodsPredicate(),
      'must have no public methods',
    );

/// Expects that selected files contain content matching [pattern].
///
/// [description] is an optional human-readable label for the matcher.
Matcher hasContent(String pattern, {String description = ''}) => ArchMatcher(
      FileContentMatchesPredicate(pattern, description: description),
      description.isEmpty ? 'content must match "$pattern"' : description,
    );

/// Expects that selected files do NOT contain content matching [pattern].
Matcher hasNoContent(String pattern) => ArchMatcher(
      NotPredicate(FileContentMatchesPredicate(
        pattern,
        description: 'contains banned pattern "$pattern"',
      )),
      'content must not match "$pattern"',
    );