import '../enums/ai_provider.dart';

extension AiProviderExtension on AiProvider {

  String get displayName => switch (this) {
        AiProvider.claudeCode => 'Claude Code',
        AiProvider.geminiCli => 'Gemini CLI',
        AiProvider.cursor => 'Cursor',
        AiProvider.githubCopilot => 'GitHub Copilot',
      };

  String get configKey => switch (this) {
        AiProvider.claudeCode => 'claude_code',
        AiProvider.geminiCli => 'gemini_cli',
        AiProvider.cursor => 'cursor',
        AiProvider.githubCopilot => 'github_copilot',
      };

  static AiProvider? fromConfigKey(String key) {
    for (final provider in AiProvider.values) {
      if (provider.configKey == key) return provider;
    }
    return null;
  }
}
