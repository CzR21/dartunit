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
      testArch('ViewModels must extend ChangeNotifier', (selector) {
        final viewModels = selector.classes(
          inFolder: viewModelsFolder,
          hasSuffix: 'ViewModel',
          exceptions: exceptions,
        );

        expect(viewModels, extendsClass('ChangeNotifier'));
      });

      testArch(
        'ViewModels must not expose injected dependencies publicly — use private final fields',
        (selector) {
          final viewModels = selector.classes(
            inFolder: viewModelsFolder,
            hasSuffix: 'ViewModel',
            exceptions: exceptions,
          );

          expect(viewModels, hasNoPublicFields());
        },
      );

      testArch(
        'ViewModels must not depend on go_router — navigation is the router\'s concern',
        (selector) {
          final viewModels = selector.classes(
            inFolder: viewModelsFolder,
            hasSuffix: 'ViewModel',
            exceptions: exceptions,
          );

          expect(viewModels, doesNotDependOnPackage('go_router'));
        },
      );

      testArch(
        'Views must not inject repositories or services directly via context.read — '
        'only ViewModels may be injected into views',
        (selector) {
          final views = selector.files(inFolder: viewsFolder, exceptions: exceptions);

          expect(views, hasNoContent(r'context\.read<[^>]*(?:Repository|Service)[^>]*>',),
          );
        },
      );

      testArch(
        'Router must instantiate ViewModels',
        (selector) {
          final router = selector.files(inFolder: routerFolder);

          expect(router, hasContent(r'\b\w+ViewModel\(', description: 'router must instantiate ViewModels',),);
        },
      );

      testArch(
        'Router must inject dependencies into ViewModels via context.read()',
        (selector) {
          final router = selector.files(inFolder: routerFolder);

          expect(router, hasContent(r':\s*context\.read\(', description: 'router must pass dependencies as named args via context.read()',),);
        },
      );
    },
    severity: severity,
    projectRoot: projectRoot,
  );
}
