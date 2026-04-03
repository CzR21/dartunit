/// Table formatting and path display extensions on [String].
extension StringTableFormat on String {

  /// Returns the display width of this string in terminal columns.
  ///
  /// Accounts for:
  /// - Wide characters (emoji, CJK, Dingbats) → 2 columns each
  /// - Zero-width characters (variation selectors, ZWJ, skin-tone modifiers) → 0
  /// - BMP chars preceded by the emoji variation selector (U+FE0F) → 2 columns
  /// - Everything else → 1 column
  int get visualWidth {
    final r = runes.toList();
    var width = 0;
    for (var i = 0; i < r.length; i++) {
      final cp = r[i];
      // Zero-width: variation selectors, ZWJ, skin-tone modifiers
      if (cp == 0xFE0F || cp == 0xFE0E || cp == 0x200D ||
          (cp >= 0x1F3FB && cp <= 0x1F3FF)) {
        continue;
      }
      // BMP char followed by emoji variation selector → emoji presentation = 2 wide
      final next = i + 1 < r.length ? r[i + 1] : -1;
      if (next == 0xFE0F) {
        width += 2;
        continue;
      }
      // Supplementary plane (U+10000+) → always wide
      if (cp > 0xFFFF) {
        width += 2;
        continue;
      }
      width += _isWideBmp(cp) ? 2 : 1;
    }
    return width;
  }

  /// Truncates the string to [maxLen] visible characters, appending [ellipsis]
  /// if the string is longer. Returns the string unchanged if within limit.
  String truncate(int maxLen, {String ellipsis = '...'}) {
    if (length <= maxLen) return this;
    return '${substring(0, maxLen - ellipsis.length)}$ellipsis';
  }

  /// Pads the string to exactly [targetWidth] terminal columns using spaces,
  /// based on [visualWidth]. Returns the string unchanged if already at or over
  /// the target width.
  String padEndToWidth(int targetWidth) {
    final vw = visualWidth;
    if (vw >= targetWidth) return this;
    return padRight(length + (targetWidth - vw));
  }

  /// Shortens a file path for display inside a report column of [maxLen] chars.
  ///
  /// Strategy:
  ///   1. If the path contains `lib/`, show from `lib/` onward.
  ///   2. Otherwise show the last two path segments.
  ///   3. Always truncates to [maxLen] if still too long.
  String shortenProjectPath(int maxLen) {
    final norm = replaceAll('\\', '/');
    final libIdx = norm.indexOf('lib/');
    if (libIdx >= 0) return norm.substring(libIdx).truncate(maxLen);
    final parts = norm.split('/');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}/${parts.last}'.truncate(maxLen);
    }
    return norm.truncate(maxLen);
  }
}

/// Returns true if [cp] is a BMP code point that occupies 2 terminal columns.
bool _isWideBmp(int cp) =>
    (cp >= 0x1100 && cp <= 0x115F) ||   // Hangul Jamo
    (cp >= 0x2E80 && cp <= 0x303E) ||   // CJK Radicals, Kangxi, CJK Symbols
    (cp >= 0x3041 && cp <= 0x33BF) ||   // Hiragana → CJK Compat
    (cp >= 0x3400 && cp <= 0x4DBF) ||   // CJK Extension A
    (cp >= 0x4E00 && cp <= 0x9FFF) ||   // CJK Unified Ideographs
    (cp >= 0xA000 && cp <= 0xA4CF) ||   // Yi Syllables / Radicals
    (cp >= 0xAC00 && cp <= 0xD7AF) ||   // Hangul Syllables
    (cp >= 0xF900 && cp <= 0xFAFF) ||   // CJK Compat Ideographs
    (cp >= 0xFE10 && cp <= 0xFE1F) ||   // Vertical Forms
    (cp >= 0xFE30 && cp <= 0xFE6F) ||   // CJK Compat Forms / Small Forms
    (cp >= 0xFF01 && cp <= 0xFF60) ||   // Fullwidth Latin / Katakana
    (cp >= 0xFFE0 && cp <= 0xFFE6) ||   // Fullwidth signs
    (cp >= 0x2600 && cp <= 0x26FF) ||   // Misc Symbols (⚠ etc.)
    (cp >= 0x2702 && cp <= 0x27BF);     // Dingbats (❌ U+274C etc.)
