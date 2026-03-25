/// Table columns for the violations report.
///
/// Each value carries its terminal [width] in visible characters and the
/// [header] label used in the table header row.
enum ReportColumn {
  severity(width: 4, header: ''),
  description(width: 30, header: ' Description'),
  file(width: 38, header: ' File'),
  line(width: 6, header: ' Line'),
  message(width: 40,  header: ' Message');

  const ReportColumn({required this.width, required this.header});

  /// Visible character width of this column.
  final int width;

  /// Column header text (pre-padded with a leading space).
  final String header;

  /// Ordered list of all column widths — used for border construction.
  static List<int> get widths => values.map((c) => c.width).toList();

  /// Ordered list of all column headers — used for the header row.
  static List<String> get headers => values.map((c) => c.header).toList();
}
