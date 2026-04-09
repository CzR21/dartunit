import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/entities/violation.dart';
import 'html_reporter.dart';

/// Generates an HTML report and writes it to `.dartunit/report.html` inside
/// [projectRoot].
///
/// Returns the absolute path of the written file, or `null` if writing fails.
class HtmlReportWriter {
  const HtmlReportWriter();

  String? write({
    required String projectRoot,
    required List<Violation> violations,
    required int rulesCount,
    required DateTime timestamp,
  }) {
    try {
      final html = HtmlReporter().generate(
        violations,
        rulesCount: rulesCount,
        timestamp: timestamp,
        projectRoot: projectRoot,
      );
      final reportDir = p.join(projectRoot, '.dartunit');
      Directory(reportDir).createSync(recursive: true);
      final reportPath = p.join(reportDir, 'report.html');
      File(reportPath).writeAsStringSync(html);
      return p.normalize(p.absolute(reportPath));
    } catch (_) {
      return null;
    }
  }
}
