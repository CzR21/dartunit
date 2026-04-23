const List<({String fileName, String content})> mvvmRuleFiles = [
  (fileName: 'mvvm_arch_test.dart', content: _mvvmArchTest),
];

const String _mvvmArchTest = '''
import 'package:dartunit/dartunit.dart';

/// MVVM Architecture rules.
/// Reference: https://docs.flutter.dev/app-architecture/guide
///
/// Adjust the folder constants below to match your project structure.
void main() {

  const _views         = 'lib/views';
  const _viewmodels    = 'lib/viewmodels';
  const _repositories  = 'lib/repositories';
  const _models        = 'lib/models';
  const _services      = 'lib/services';
  const _data          = 'lib/data';

  testArchGroup('View layer \u2014 must bind to ViewModel only', () {
      testArch('Views must not access the data layer directly', (arch) {
        final viewSelector = arch.classes(folder: _views);

        expect(viewSelector, doesNotDependOn(_data));
      });

      testArch('Views must not access models directly', (arch) {
        final viewSelector = arch.classes(folder: _views);

        expect(viewSelector, doesNotDependOn(_models));
      });

      testArch('Views must not depend on services directly', (arch) {
        final viewSelector = arch.classes(folder: _views);

        expect(viewSelector, doesNotDependOn(_services));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('ViewModel layer \u2014 no direct data access, no cross-VM dependencies', () {
      testArch('ViewModels must not access the data layer directly', (arch) {
        final viewModelSelector = arch.classes(namePattern: r'.*ViewModel\$');

        expect(viewModelSelector, doesNotDependOn(_data));
      });

      testArch('ViewModels must not depend on other ViewModels', (arch) {
        final viewModelSelector = arch.classes(namePattern: r'.*ViewModel\$');

        expect(viewModelSelector, doesNotDependOn(_viewmodels));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository layer \u2014 must not reach into UI or depend on siblings', () {
      testArch('Repositories must not depend on views', (arch) {
        final repositorySelector = arch.classes(namePattern: r'.*Repository\$');

        expect(repositorySelector, doesNotDependOn(_views));
      });

      testArch('Repositories must not depend on viewmodels', (arch) {
        final repositorySelector = arch.classes(namePattern: r'.*Repository\$');

        expect(repositorySelector, doesNotDependOn(_viewmodels));
      });

      testArch('Repositories must not depend on other repositories', (arch) {
        final repositorySelector = arch.classes(namePattern: r'.*Repository\$');

        expect(repositorySelector, doesNotDependOn(_repositories));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Service layer \u2014 must not reach into UI or repositories', () {
      testArch('Services must not depend on views', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_views));
      });

      testArch('Services must not depend on viewmodels', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_viewmodels));
      });

      testArch('Services must not depend on repositories', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_repositories));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository contracts \u2014 abstract interfaces for testability', () {
      testArch('Repository interfaces must be abstract', (arch) {
        final repositorySelector = arch.classes(
          folder: _repositories,
          namePattern: r'(?!.*Impl\$).*Repository\$',
        );

        expect(repositorySelector, isAbstractClass());
      });

      testArch('Repository implementations must not be abstract', (arch) {
        final repositoryImplSelector = arch.classes(namePattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, isConcreteClass());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('ViewModel cohesion \u2014 focused responsibility', () {
      testArch('ViewModels must have at most 10 public methods', (arch) {
        final viewModelSelector = arch.classes(namePattern: r'.*ViewModel\$');

        expect(viewModelSelector, hasMaxMethods(10));
      });

      testArch('ViewModels must have at most 15 imports', (arch) {
        final viewModelSelector = arch.classes(namePattern: r'.*ViewModel\$');

        expect(viewModelSelector, hasMaxImports(15));
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('Models \u2014 immutable value objects', () {
      testArch('Model classes must have all-final fields', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, hasAllFinalFields());
      });

      testArch('Model classes must not expose public mutable fields', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Services \u2014 stateless and injectable', () {
      testArch('Service classes must have all-final fields', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, hasAllFinalFields());
      });
    },
    severity: RuleSeverity.error,
  );

  // ---------------------------------------------------------------------------
  // GoRouter \u2014 dependency injection boundary
  //
  // Based on: https://docs.flutter.dev/app-architecture/case-study/dependency-injection
  //
  // The router is the only place where repositories/services are read from
  // context and injected into ViewModels. Views must not inject repositories
  // directly. Remove or adjust this group if you are not using GoRouter.
  // ---------------------------------------------------------------------------

  const _router = 'lib/router';

  mvvmGoRouterInjection(
    viewsFolder: _views,
    viewModelsFolder: _viewmodels,
    routerFolder: _router,
    severity: RuleSeverity.error,
  );
}
''';
