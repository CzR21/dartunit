import 'package:test/test.dart';

import '../core/enums/rule_severity.dart';
import '../runner/arch_runner.dart';
import '../runner/arch_matchers.dart';

/// Enforces the MVVM + GoRouter dependency injection pattern.
///
/// Based on: https://docs.flutter.dev/app-architecture/case-study/dependency-injection
///
/// In this pattern, the GoRouter configuration is the injection boundary:
/// repositories/services are exposed via Provider at the top level, and the
/// router creates each ViewModel by reading them from context — views never
/// access repositories directly.
///
/// ```dart
/// void main() => mvvmGoRouterInjection(
///   viewsFolder:      'lib/ui/views',
///   viewModelsFolder: 'lib/ui/viewmodels',
///   routerFolder:     'lib/router',
/// );
/// ```
void mvvmGoRouterInjection({
  required String viewsFolder,
  required String viewModelsFolder,
  String routerFolder = 'lib/router',
  RuleSeverity severity = RuleSeverity.error,
  List<String> exceptions = const [],
  String projectRoot = '.',
}) {
  testArchGroup(
    'MVVM + GoRouter — dependency injection rules',
    () {
      testArch('ViewModels must extend ChangeNotifier', (arch) {
        final viewModels = arch.classes(
          folder: viewModelsFolder,
          suffix: 'ViewModel',
          exceptions: exceptions,
        );
        expect(viewModels, extendsClass('ChangeNotifier'));
      });

      testArch(
        'ViewModels must not expose injected dependencies publicly — use private final fields',
        (arch) {
          final viewModels = arch.classes(
            folder: viewModelsFolder,
            suffix: 'ViewModel',
            exceptions: exceptions,
          );
          expect(viewModels, hasNoPublicFields());
        },
      );

      testArch(
        'ViewModels must have all-final fields — dependencies are immutable after injection',
        (arch) {
          final viewModels = arch.classes(
            folder: viewModelsFolder,
            suffix: 'ViewModel',
            exceptions: exceptions,
          );
          expect(viewModels, hasAllFinalFields());
        },
      );

      testArch(
        'ViewModels must not depend on go_router — navigation is the router\'s concern',
        (arch) {
          final viewModels = arch.classes(
            folder: viewModelsFolder,
            suffix: 'ViewModel',
            exceptions: exceptions,
          );
          expect(viewModels, doesNotDependOnPackage('go_router'));
        },
      );

      testArch(
        'Views must not inject repositories or services directly via context.read — '
        'only ViewModels may be injected into views',
        (arch) {
          final views = arch.files(folder: viewsFolder, exceptions: exceptions);
          expect(
            views,
            hasNoContent(
              r'context\.read<[^>]*(?:Repository|Service)[^>]*>',
            ),
          );
        },
      );

      testArch(
        'Router must inject dependencies into ViewModels via context.read()',
        (arch) {
          final router = arch.files(folder: routerFolder);
          expect(
            router,
            hasContent(
              r'context\.read\(',
              description: 'router must inject dependencies via context.read()',
            ),
          );
        },
      );
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
