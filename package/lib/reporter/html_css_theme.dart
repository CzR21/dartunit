/// CSS stylesheet for the dartunit HTML report — supports dark (default) and light themes.
abstract final class HtmlCssTheme {
  static String get stylesheet => r'''
    * { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg:          #17191C;
      --bg-surface:  #23262F;
      --border:      #334155;
      --text:        #e2e8f0;
      --text-muted:  #94a3b8;
      --text-dim:    #64748b;
      --accent:      #93C5FD;
      --hover-row:   #1a2540;
      --footer-text: #475569;
      --file-link:        #93C5FD;
      --file-link-hover:  #bfdbfe;
      --file-link-dash:   #3b5998;
      --badge-critical-bg: #3b0764; --badge-critical-fg: #a855f7;
      --badge-error-bg:    #450a0a; --badge-error-fg:    #fca5a5;
      --badge-warning-bg:  #451a03; --badge-warning-fg:  #fcd34d;
      --badge-info-bg:     #0c2642; --badge-info-fg:     #93C5FD;
      --status-pass-bg: #064e3b; --status-pass-fg: #34d399; --status-pass-border: #065f46;
      --status-fail-bg: #450a0a; --status-fail-fg: #f87171; --status-fail-border: #7f1d1d;
      --status-warn-bg: #451a03; --status-warn-fg: #fb923c; --status-warn-border: #7c2d12;
      --num-critical: #a855f7;
      --num-error:    #f87171;
      --num-warning:  #fbbf24;
      --num-info:     #93C5FD;
      --no-viol-bg: #064e3b; --no-viol-border: #065f46; --no-viol-fg: #34d399;
    }

    [data-theme="light"] {
      --bg:          #f8fafc;
      --bg-surface:  #ffffff;
      --border:      #e2e8f0;
      --text:        #1e293b;
      --text-muted:  #475569;
      --text-dim:    #94a3b8;
      --accent:      #2563eb;
      --hover-row:   #f1f5f9;
      --footer-text: #94a3b8;
      --file-link:        #2563eb;
      --file-link-hover:  #1d4ed8;
      --file-link-dash:   #93c5fd;
      --badge-critical-bg: #f3e8ff; --badge-critical-fg: #7e22ce;
      --badge-error-bg:    #fee2e2; --badge-error-fg:    #dc2626;
      --badge-warning-bg:  #fef9c3; --badge-warning-fg:  #a16207;
      --badge-info-bg:     #dbeafe; --badge-info-fg:     #1d4ed8;
      --status-pass-bg: #dcfce7; --status-pass-fg: #16a34a; --status-pass-border: #bbf7d0;
      --status-fail-bg: #fee2e2; --status-fail-fg: #dc2626; --status-fail-border: #fecaca;
      --status-warn-bg: #ffedd5; --status-warn-fg: #ea580c; --status-warn-border: #fed7aa;
      --num-critical: #7e22ce;
      --num-error:    #dc2626;
      --num-warning:  #d97706;
      --num-info:     #1d4ed8;
      --no-viol-bg: #f0fdf4; --no-viol-border: #bbf7d0; --no-viol-fg: #16a34a;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, monospace;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      transition: background 0.2s, color 0.2s;
    }
    main { max-width: 1400px; margin: 0 auto; padding: 0 0 40px; }

    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 24px 32px;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
      transition: background 0.2s, border-color 0.2s;
    }
    h1 { font-size: 1.5rem; font-weight: 700; color: var(--accent); }
    .subtitle { font-size: 0.875rem; color: var(--text-muted); margin-top: 4px; }
    .meta { font-size: 0.75rem; color: var(--text-dim); margin-top: 6px; font-family: monospace; }

    .header-right { display: flex; align-items: center; gap: 16px; }

    /* ── theme toggle ── */
    .theme-toggle {
      display: flex;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      user-select: none;
    }
    .theme-toggle input { display: none; }
    .toggle-icon { font-size: 0.85rem; line-height: 1; }
    .toggle-track {
      position: relative;
      width: 40px;
      height: 22px;
      background: var(--border);
      border-radius: 11px;
      transition: background 0.2s;
      flex-shrink: 0;
    }
    .theme-toggle input:checked ~ .toggle-track { background: var(--accent); }
    .toggle-thumb {
      position: absolute;
      top: 3px;
      left: 3px;
      width: 16px;
      height: 16px;
      background: #fff;
      border-radius: 50%;
      box-shadow: 0 1px 3px rgba(0,0,0,0.3);
      transition: left 0.2s;
    }
    .theme-toggle input:checked ~ .toggle-track .toggle-thumb { left: 21px; }

    .status {
      padding: 6px 18px;
      border-radius: 6px;
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 0.1em;
      white-space: nowrap;
      transition: background 0.2s, color 0.2s, border-color 0.2s;
    }
    .status.pass { background: var(--status-pass-bg); color: var(--status-pass-fg); border: 1px solid var(--status-pass-border); }
    .status.fail { background: var(--status-fail-bg); color: var(--status-fail-fg); border: 1px solid var(--status-fail-border); }
    .status.warn { background: var(--status-warn-bg); color: var(--status-warn-fg); border: 1px solid var(--status-warn-border); }

    .summary {
      display: flex;
      gap: 12px;
      padding: 0 32px;
      margin-bottom: 24px;
    }
    .stat {
      background: var(--bg-surface);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 14px 24px;
      display: flex;
      flex-direction: column;
      align-items: center;
      min-width: 80px;
      transition: background 0.2s, border-color 0.2s;
    }
    .stat .num { font-size: 1.75rem; font-weight: 700; color: var(--text); }
    .stat .lbl {
      font-size: 0.7rem;
      color: var(--text-dim);
      text-transform: uppercase;
      letter-spacing: 0.08em;
      margin-top: 2px;
    }
    .stat.critical .num { color: var(--num-critical); }
    .stat.error    .num { color: var(--num-error); }
    .stat.warning  .num { color: var(--num-warning); }
    .stat.info     .num { color: var(--num-info); }

    .no-violations {
      margin: 0 32px;
      background: var(--no-viol-bg);
      border: 1px solid var(--no-viol-border);
      border-radius: 8px;
      padding: 28px;
      text-align: center;
      color: var(--no-viol-fg);
      font-size: 1.125rem;
      transition: background 0.2s, border-color 0.2s, color 0.2s;
    }

    .violations { padding: 0 32px; overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
    thead { background: var(--bg-surface); position: sticky; top: 0; transition: background 0.2s; }
    th {
      padding: 10px 12px;
      text-align: left;
      font-size: 0.7rem;
      font-weight: 600;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      border-bottom: 1px solid var(--border);
      white-space: nowrap;
    }
    td { padding: 9px 12px; border-bottom: 1px solid var(--bg-surface); vertical-align: top; color: var(--text); transition: background 0.15s, color 0.2s; }
    tr:hover td { background: var(--hover-row); }
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
      transition: background 0.2s, color 0.2s;
    }
    .badge.critical { background: var(--badge-critical-bg); color: var(--badge-critical-fg); }
    .badge.error    { background: var(--badge-error-bg);    color: var(--badge-error-fg); }
    .badge.warning  { background: var(--badge-warning-bg);  color: var(--badge-warning-fg); }
    .badge.info     { background: var(--badge-info-bg);     color: var(--badge-info-fg); }

    .rule-id   { font-family: monospace; color: var(--text-muted); white-space: nowrap; }
    .file-path { font-family: monospace; color: var(--file-link); word-break: break-all; }
    .line-num  { font-family: monospace; color: var(--text-dim); white-space: nowrap; text-align: right; }
    .message   { color: var(--text-muted); }
    .file-link {
      font-family: monospace;
      color: var(--file-link);
      text-decoration: none;
      word-break: break-all;
      border-bottom: 1px dashed var(--file-link-dash);
      transition: color 0.15s, border-color 0.15s;
    }
    .file-link:hover {
      color: var(--file-link-hover);
      border-bottom-color: var(--file-link);
    }

    footer {
      text-align: center;
      padding: 20px 32px;
      color: var(--footer-text);
      font-size: 0.75rem;
      border-top: 1px solid var(--bg-surface);
      margin-top: 32px;
      transition: color 0.2s, border-color 0.2s;
    }
    ''';
}
