import 'package:dartunit/core/entities/subject.dart';
import 'package:dartunit/dartunit.dart';

/// Creates a [Subject] wrapping an [AnalyzedClass] for use in predicate tests.
Subject classSubject(
  String name, {
  List<String> annotations = const [],
  List<String> imports = const [],
  List<AnalyzedMethod> methods = const [],
  List<AnalyzedField> fields = const [],
  bool isAbstract = false,
  bool isMixin = false,
  bool isEnum = false,
  bool isExtension = false,
  String? extendedType,
  List<String> implementedTypes = const [],
  List<String> mixinTypes = const [],
  String filePath = 'lib/src/fake.dart',
}) {
  final cls = AnalyzedClass(
    name: name,
    filePath: filePath,
    packagePath: 'package:app/$filePath',
    annotations: annotations,
    imports: imports,
    methods: methods,
    fields: fields,
    isAbstract: isAbstract,
    isMixin: isMixin,
    isEnum: isEnum,
    isExtension: isExtension,
    extendedType: extendedType,
    implementedTypes: implementedTypes,
    mixinTypes: mixinTypes,
  );
  return Subject(name: name, filePath: filePath, element: cls);
}

/// Returns an empty [AnalysisContext] sufficient for unit-testing predicates
/// that do not need global project information.
AnalysisContext emptyCtx() => AnalysisContext(
      classes: [],
      files: [],
      dependencyGraph: DependencyGraph(),
      projectRoot: '/project',
    );

/// Creates an [AnalyzedMethod] with the given [name] and a `void` return type.
AnalyzedMethod method(String name, {String returnType = 'void'}) =>
    AnalyzedMethod(name: name, returnType: returnType);

/// Creates a `final` instance [AnalyzedField].
AnalyzedField finalField(String name, {String type = 'dynamic'}) =>
    AnalyzedField(name: name, type: type, isFinal: true);

/// Creates a mutable (non-final, non-const, non-static) instance [AnalyzedField].
AnalyzedField mutableField(String name, {String type = 'dynamic'}) =>
    AnalyzedField(name: name, type: type);

/// Creates a `static` [AnalyzedField].
AnalyzedField staticField(String name, {String type = 'dynamic'}) =>
    AnalyzedField(name: name, type: type, isStatic: true);

/// Creates a [Subject] wrapping an [AnalyzedFile] for use in predicate tests.
///
/// [fileName] is the bare file name (e.g. `user_service.dart`).
/// [folder] is the containing folder path (e.g. `lib/services`).
Subject fileSubject(
  String fileName, {
  String folder = 'lib/src',
  List<String> imports = const [],
}) {
  final filePath = '$folder/$fileName';
  final file = AnalyzedFile(
    filePath: filePath,
    packagePath: 'package:app/$filePath',
    imports: imports,
  );
  return Subject(name: fileName, filePath: filePath, element: file);
}
