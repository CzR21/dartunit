import '../../core/constants/dart_keywords.dart';
import '../../utils/source_helper.dart';
import '../models/analyzed_method.dart';

/// Parses method declarations from a Dart class body.
class MethodParser {
  const MethodParser();

  static final _methodRegex = RegExp(
    r'(?:^|\n)[ \t]*'
    r'((?:@\w+(?:\([^)]*\))?\s+)*)'                         // annotations           (group 1)
    r'(?:(?:static|abstract|override)\s+)*'                 // modifiers
    r'(?:(?:void|bool|int|double|String|num|dynamic)\s+|'   // primitive return type…
    r'[A-Z]\w*(?:<[^>]*>)?\s+)'                             // …or capitalised type (required)
    r'(\w+)\s*\(',                                          // method name           (group 2)
    multiLine: true,
  );

  List<AnalyzedMethod> parse(String classBody) {
    final methods = <AnalyzedMethod>[];

    for (final match in _methodRegex.allMatches(classBody)) {
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
}
