import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/enums/ai_provider.dart';
import 'providers/claude_code_generator.dart';
import 'providers/cursor_generator.dart';
import 'providers/gemini_cli_generator.dart';
import 'providers/github_copilot_generator.dart';

class GeneratedAiFile {
  final String relativePath;
  final String content;

  const GeneratedAiFile(this.relativePath, this.content);
}

abstract interface class AiFileGenerator {
  List<GeneratedAiFile> get files;

  factory AiFileGenerator.forProvider(AiProvider provider) => switch (provider) {
        AiProvider.claudeCode => ClaudeCodeGenerator(),
        AiProvider.geminiCli => GeminiCliGenerator(),
        AiProvider.cursor => CursorGenerator(),
        AiProvider.githubCopilot => GithubCopilotGenerator(),
      };

  static List<String> writeAll(AiProvider provider, String projectRoot) {
    final generator = AiFileGenerator.forProvider(provider);
    final created = <String>[];

    for (final file in generator.files) {
      final fullPath = p.join(projectRoot, file.relativePath);
      final dir = Directory(p.dirname(fullPath));
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File(fullPath).writeAsStringSync(file.content);
      created.add(file.relativePath);
    }

    return created;
  }
}
