/// Dart keywords and common built-in identifiers that must not be treated
/// as class, method, or field names when matched by the regex parsers.
const Set<String> dartKeywords = {
  'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'break',
  'continue', 'return', 'new', 'null', 'true', 'false', 'var', 'final',
  'const', 'dynamic', 'void', 'int', 'double', 'String', 'bool', 'List',
  'Map', 'Set', 'print', 'super', 'this', 'await', 'async', 'yield',
  'static', 'abstract', 'class', 'extends', 'implements', 'with',
  'import', 'export', 'part', 'library', 'typedef',
};
