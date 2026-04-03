import '../core/constants/dart_keywords.dart';
import 'path_helper.dart';
import 'source_helper.dart';
import '../analyzer/models/analyzed_class.dart';
import '../analyzer/models/analyzed_field.dart';
import '../analyzer/models/analyzed_method.dart';

/// Parses class declarations from the raw source text of a single Dart file.
class ClassParserHelper {

  const ClassParserHelper();

  static final _classRegex = RegExp(
    r'(?:^|\n)\s*'
    r'((?:@\w+(?:\([^)]*\))?\s+)*)'                         // annotations          (group 1)
    r'((?:(?:abstract|sealed|final|base|interface)\s+)*)'   // modifiers            (group 2)
    r'(class|mixin|enum|extension)\s+'                      // declaration kind     (group 3)
    r'(\w+)'                                                // type name            (group 4)
    r'(?:\s+extends\s+(\w+))?'                              // extends clause       (group 5)
    r'(?:\s+implements\s+([\w,\s]+))?'                      // implements clause    (group 6)
    r'(?:\s+with\s+([\w,\s]+))?',                           // with clause          (group 7)
  );

  static final _methodRegex = RegExp(
    r'(?:^|\n)[ \t]*'                                        // início de linha (âncora)
    r'((?:@\w+(?:\([^)]*\))?\s+)*)'                         // annotations           (group 1)
    r'(?:(?:static|abstract|override)\s+)*'                 // modifiers
    r'(?:(?:void|bool|int|double|String|num|dynamic)\s+|'   // tipo primitivo...
    r'[A-Z]\w*(?:<[^>]*>)?\s+)'                             // ...ou tipo com maiúscula (obrigatório)
    r'(\w+)\s*\(',                                          // method name           (group 2)
    multiLine: true,
  );

  static final _fieldRegex = RegExp(
    r'(?:^|\n)[ \t]*'                     // início de linha (âncora)
    r'(static\s+)?(final\s+|const\s+)?'   // modifiers   (groups 1, 2)
    r'([\w<>, ?]+)\s+'                    // declared type (group 3)
    r'(\w+)\s*[;=]',                      // field name    (group 4)
    multiLine: true,
  );

  /// Parses all type declarations from [content] and returns them as a list
  /// of [AnalyzedClass] objects.
  ///
  /// [filePath] and [packagePath] are stamped onto every class.
  /// [imports] (already resolved by [ImportParser]) are shared across all
  /// classes in the same file.
  List<AnalyzedClass> parse(
      String filePath,
      String packagePath,
      List<String> imports,
      String content,
      ) {
    final classes = <AnalyzedClass>[];
    final lineOffsets = SourceHelper.buildLineOffsets(content);

    for (final match in _classRegex.allMatches(content)) {
      final annotationsRaw = match.group(1) ?? '';
      final isAbstract = (match.group(2) ?? '').contains('abstract');
      final kind = match.group(3)!;
      final name = match.group(4)!;
      final extendedType = match.group(5);
      final implementsRaw = match.group(6) ?? '';
      final withRaw = match.group(7) ?? '';

      final implementedTypes = implementsRaw.isEmpty
          ? <String>[]
          : implementsRaw.split(',').map((s) => s.trim()).toList();

      final mixinTypes = withRaw.isEmpty
          ? <String>[]
          : withRaw.split(',').map((s) => s.trim()).toList();

      final body = SourceHelper.extractClassBody(content, match.end);

      classes.add(AnalyzedClass(
        name: name,
        filePath: PathHelper.normalize(filePath),
        packagePath: packagePath,
        annotations: SourceHelper.extractAnnotationNames(annotationsRaw),
        imports: imports,
        extendedType: extendedType,
        implementedTypes: implementedTypes,
        mixinTypes: mixinTypes,
        methods: _parseMethods(body),
        fields: _parseFields(body),
        isAbstract: isAbstract,
        isMixin: kind == 'mixin',
        isEnum: kind == 'enum',
        isExtension: kind == 'extension',
        line: SourceHelper.lineAt(lineOffsets, match.start),
      ));
    }

    return classes;
  }

  List<AnalyzedMethod> _parseMethods(String body) {
    final methods = <AnalyzedMethod>[];

    for (final match in _methodRegex.allMatches(body)) {
      final name = match.group(2)!;
      if (dartKeywords.contains(name)) continue;

      final annotations =
      SourceHelper.extractAnnotationNames(match.group(1) ?? '');

      methods.add(AnalyzedMethod(
        name: name,
        returnType: 'dynamic',
        annotations: annotations,
        isOverride: annotations.contains('override'),
      ));
    }

    return methods;
  }

  List<AnalyzedField> _parseFields(String body) {
    final fields = <AnalyzedField>[];

    for (final match in _fieldRegex.allMatches(body)) {
      final isStatic = match.group(1) != null;
      final modifier = match.group(2) ?? '';
      final type     = match.group(3)!.trim();
      final name     = match.group(4)!;

      if (dartKeywords.contains(name) || dartKeywords.contains(type)) continue;
      // Ignora getters e setters (ex: "List<Object> get props =>")
      if (RegExp(r'\bget\b|\bset\b').hasMatch(type)) continue;

      fields.add(AnalyzedField(
        name: name,
        type: type,
        isFinal: modifier.startsWith('final'),
        isConst: modifier.startsWith('const'),
        isStatic: isStatic,
      ));
    }

    return fields;
  }
}
