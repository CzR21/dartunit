import '../../core/enums/ai_provider.dart';
import '../../core/extensions/ai_provider_extension.dart';

const String aiConfigured = 'AI integration configured successfully!';
const String aiSkipped = 'AI integration skipped.';
const String aiPrompt = 'Configure AI assistance for rule generation?';
const String aiChooseProviders = 'Select your AI tools (space to toggle, enter to confirm):';
const String aiSwitchPrompt = 'Update configured providers?';

String aiCurrentProviders(List<AiProvider> providers) =>
    'Current AI providers: ${providers.map((p) => p.displayName).join(', ')}';

String aiCreatedFile(String path) => '${_darkGray('Created')}  $path';

List<String> aiNextSteps(List<AiProvider> providers) {
  if (providers.length == 1) return _stepsFor(providers.first);

  final steps = <String>[];
  for (final provider in providers) {
    for (final step in _stepsFor(provider)) {
      steps.add('[${provider.displayName}] $step');
    }
  }
  return steps;
}

List<String> _stepsFor(AiProvider provider) => switch (provider) {
      AiProvider.claudeCode => [
          'Open this project in Claude Code.',
          'Type  /dartunit  to generate rules from your project structure.',
          'Or tag the  dartunit  agent for explanations and suggestions.',
        ],
      AiProvider.geminiCli => [
          'Run  gemini  in this project directory.',
          'Ask: "Generate DartUnit architecture rules for this project."',
        ],
      AiProvider.cursor => [
          'Open this project in Cursor.',
          'Ask: "Generate DartUnit rules for this project structure."',
          'The rule in .cursor/rules/dartunit.mdc will guide the AI automatically.',
        ],
      AiProvider.githubCopilot => [
          'Open this project in VS Code with GitHub Copilot.',
          'Use Copilot Chat and ask: "Generate DartUnit architecture rules."',
          'Copilot will use .github/copilot-instructions.md as context.',
        ],
    };

// Inline ANSI helper — avoids importing mason_logger internals here.
String _darkGray(String text) => '\x1B[90m$text\x1B[0m';
