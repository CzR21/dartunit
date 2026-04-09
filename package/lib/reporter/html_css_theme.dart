/// Dark-theme CSS stylesheet for the dartunit HTML report.
abstract final class HtmlCssTheme {
  static String get stylesheet => r'''
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, monospace;
      background: #17191C;
      color: #e2e8f0;
      min-height: 100vh;
    }
    main { max-width: 1400px; margin: 0 auto; padding: 0 0 40px; }

    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 24px 32px;
      background: #23262F;
      border-bottom: 1px solid #334155;
      margin-bottom: 24px;
    }
    h1 { font-size: 1.5rem; font-weight: 700; color: #93C5FD; }
    .subtitle { font-size: 0.875rem; color: #94a3b8; margin-top: 4px; }
    .meta { font-size: 0.75rem; color: #64748b; margin-top: 6px; font-family: monospace; }
    .status {
      padding: 6px 18px;
      border-radius: 6px;
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 0.1em;
      white-space: nowrap;
    }
    .status.pass { background: #064e3b; color: #34d399; border: 1px solid #065f46; }
    .status.fail { background: #450a0a; color: #f87171; border: 1px solid #7f1d1d; }
    .status.warn { background: #451a03; color: #fb923c; border: 1px solid #7c2d12; }

    .summary {
      display: flex;
      gap: 12px;
      padding: 0 32px;
      margin-bottom: 24px;
    }
    .stat {
      background: #23262F;
      border: 1px solid #334155;
      border-radius: 8px;
      padding: 14px 24px;
      display: flex;
      flex-direction: column;
      align-items: center;
      min-width: 80px;
    }
    .stat .num { font-size: 1.75rem; font-weight: 700; color: #e2e8f0; }
    .stat .lbl {
      font-size: 0.7rem;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      margin-top: 2px;
    }
    .stat.critical .num { color: #a855f7; }
    .stat.error .num    { color: #f87171; }
    .stat.warning .num  { color: #fbbf24; }
    .stat.info .num     { color: #93C5FD; }

    .no-violations {
      margin: 0 32px;
      background: #064e3b;
      border: 1px solid #065f46;
      border-radius: 8px;
      padding: 28px;
      text-align: center;
      color: #34d399;
      font-size: 1.125rem;
    }

    .violations { padding: 0 32px; overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
    thead { background: #23262F; position: sticky; top: 0; }
    th {
      padding: 10px 12px;
      text-align: left;
      font-size: 0.7rem;
      font-weight: 600;
      color: #94a3b8;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      border-bottom: 1px solid #334155;
      white-space: nowrap;
    }
    td { padding: 9px 12px; border-bottom: 1px solid #23262F; vertical-align: top; }
    tr:hover td { background: #1a2540; }
    tr.critical td { border-left: 3px solid #a855f7; }
    tr.error    td { border-left: 3px solid #ef4444; }
    tr.warning  td { border-left: 3px solid #f59e0b; }
    tr.info     td { border-left: 3px solid #0ea5e9; }

    .badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 0.68rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      white-space: nowrap;
    }
    .badge.critical { background: #3b0764; color: #a855f7; }
    .badge.error    { background: #450a0a; color: #fca5a5; }
    .badge.warning  { background: #451a03; color: #fcd34d; }
    .badge.info     { background: #0c2642; color: #93C5FD; }

    .rule-id   { font-family: monospace; color: #94a3b8; white-space: nowrap; }
    .file-path { font-family: monospace; color: #93C5FD; word-break: break-all; }
    .line-num  { font-family: monospace; color: #64748b; white-space: nowrap; text-align: right; }
    .message   { color: #cbd5e1; }
    .file-link {
      font-family: monospace;
      color: #93C5FD;
      text-decoration: none;
      word-break: break-all;
      border-bottom: 1px dashed #3b5998;
      transition: color 0.15s, border-color 0.15s;
    }
    .file-link:hover {
      color: #bfdbfe;
      border-bottom-color: #93C5FD;
    }

    footer {
      text-align: center;
      padding: 20px 32px;
      color: #475569;
      font-size: 0.75rem;
      border-top: 1px solid #23262F;
      margin-top: 32px;
    }
    ''';
}
