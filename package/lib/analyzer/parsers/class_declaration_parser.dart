import '../../utils/path_helper.dart';
import '../../utils/source_helper.dart';
import '../models/analyzed_class.dart';
import 'field_parser.dart';
import 'method_parser.dart';

/// Parses class (and mixin / enum / extension) declarations from the raw
/// source text of a single Dart file.
///
/// Delegates method and field extraction to [MethodParser] and [FieldParser].
class ClassDeclarationParser {
  const ClassDeclarationParser();

  static const _methodParser = MethodParser();
  static const _fieldParser  = FieldParser();

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

  /// Parses all type declarations from [content] and returns them as
  /// [AnalyzedClass] instances.
  ///
  /// [filePath] and [packagePath] are stamped onto every class.
  /// [imports] (resolved by [ImportParser]) are shared across all classes
  /// in the same file.
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
        methods: _methodParser.parse(body),
        fields: _fieldParser.parse(body),
        isAbstract: isAbstract,
        isMixin: kind == 'mixin',
        isEnum: kind == 'enum',
        isExtension: kind == 'extension',
        line: SourceHelper.lineAt(lineOffsets, match.start),
      ));
    }

    return classes;
  }
}
