import '../../cli/templates/bloc_template.dart';
import '../../cli/templates/clean_template.dart';
import '../../cli/templates/mvc_template.dart';
import '../../cli/templates/mvvm_template.dart';
import 'arch_template.dart';

extension ArchTemplateExtension on ArchTemplate {
  String get label => switch (this) {
        ArchTemplate.bloc => 'BLoC',
        ArchTemplate.clean => 'Clean Architecture',
        ArchTemplate.mvc => 'MVC',
        ArchTemplate.mvvm => 'MVVM',
      };

  List<({String fileName, String content})> get ruleFiles => switch (this) {
        ArchTemplate.bloc => blocRuleFiles,
        ArchTemplate.clean => cleanRuleFiles,
        ArchTemplate.mvc => mvcRuleFiles,
        ArchTemplate.mvvm => mvvmRuleFiles,
      };

  static ArchTemplate? fromString(String value) {
    return ArchTemplate.values.where((t) => t.name == value).firstOrNull;
  }
}
