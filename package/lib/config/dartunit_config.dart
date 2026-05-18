import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/enums/ai_provider.dart';
import '../core/extensions/ai_provider_extension.dart';

class DartunitConfig {
  final List<AiProvider> aiProviders;

  const DartunitConfig({this.aiProviders = const []});

  static const String dirName = '.dartunit';
  static const String fileName = 'dartunit.json';

  static String _configPath(String projectRoot) =>
      p.join(projectRoot, dirName, fileName);

  static DartunitConfig read(String projectRoot) {
    final file = File(_configPath(projectRoot));
    if (!file.existsSync()) return const DartunitConfig();

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final aiMap = json['ai'] as Map<String, dynamic>?;
    final providersList = aiMap?['providers'] as List<dynamic>?;

    final providers = providersList
            ?.map((k) => AiProviderExtension.fromConfigKey(k as String))
            .whereType<AiProvider>()
            .toList() ??
        const [];

    return DartunitConfig(aiProviders: providers);
  }

  void write(String projectRoot) {
    final file = File(_configPath(projectRoot));
    file.parent.createSync(recursive: true);
    final json = {
      'ai': {
        'providers': aiProviders.map((p) => p.configKey).toList(),
      },
    };
    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(json));
  }
}
