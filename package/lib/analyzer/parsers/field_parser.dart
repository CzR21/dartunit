import '../../core/constants/dart_keywords.dart';
import '../models/analyzed_field.dart';

/// Parses field declarations from a Dart class body.
class FieldParser {
  const FieldParser();

  static final _fieldRegex = RegExp(
    r'(?:^|\n)[ \t]*'
    r'(static\s+)?(final\s+|const\s+)?'   // modifiers   (groups 1, 2)
    r'([\w<>, ?]+)\s+'                    // declared type (group 3)
    r'(\w+)\s*[;=]',                      // field name    (group 4)
    multiLine: true,
  );

  List<AnalyzedField> parse(String classBody) {
    final fields = <AnalyzedField>[];

    for (final match in _fieldRegex.allMatches(classBody)) {
      final isStatic = match.group(1) != null;
      final modifier = match.group(2) ?? '';
      final type     = match.group(3)!.trim();
      final name     = match.group(4)!;

      if (dartKeywords.contains(name) || dartKeywords.contains(type)) continue;
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
