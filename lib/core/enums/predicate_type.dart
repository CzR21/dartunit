/// All atomic predicate types supported in `dartunit.yaml`.
///
/// Composite keys (`not`, `and`, `or`) are handled separately by
/// [YamlRuleParser] because they are recursive and don't follow the
/// `type` / `value` pattern.
enum PredicateType {
  // Dependency
  dependOnFolder('dependOnFolder'),
  dependOnPackage('dependOnPackage'),
  onlyDependOnFolders('onlyDependOnFolders'),
  maxImports('maxImports'),
  hasCircularDependency('hasCircularDependency'),

  // Naming
  nameEndsWith('nameEndsWith'),
  nameStartsWith('nameStartsWith'),
  nameMatchesPattern('nameMatchesPattern'),
  nameContains('nameContains'),

  // Annotations
  annotatedWith('annotatedWith'),
  notAnnotatedWith('notAnnotatedWith'),

  // Inheritance
  extendsType('extends'),
  implementsType('implements'),
  usesMixin('usesMixin'),

  // Structural kind
  isAbstract('isAbstract'),
  isEnum('isEnum'),
  isMixin('isMixin'),
  isExtension('isExtension'),
  isConcrete('isConcrete'),

  // Metrics
  maxMethods('maxMethods'),
  maxFields('maxFields'),
  minMethods('minMethods'),
  minFields('minFields'),

  // Fields
  hasAllFinalFields('hasAllFinalFields'),
  hasNoPublicFields('hasNoPublicFields'),

  // Methods
  hasMethod('hasMethod'),
  hasNoPublicMethods('hasNoPublicMethods'),

  // File content
  fileContentMatches('fileContentMatches');

  const PredicateType(this.yamlKey);

  /// The string value used in `dartunit.yaml`.
  final String yamlKey;

  /// Returns the matching [PredicateType] for [value], or `null` if unknown.
  static PredicateType? fromString(String? value) {
    if (value == null) return null;
    final matches = PredicateType.values.where((e) => e.yamlKey == value);
    return matches.isEmpty ? null : matches.first;
  }
}


