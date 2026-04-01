const List<({String fileName, String content})> cleanRuleFiles = [
  (fileName: 'clean_test_arch.dart', content: _cleanArchTest),
];

const String _cleanArchTest = '''
import 'package:dartunit/dartunit.dart';

/// Clean Architecture rules.
/// Reference: https://docs.flutter.dev/app-architecture/guide
///
/// Adjust the folder constants below to match your project structure.
void main() {

  const _domain       = 'lib/domain';
  const _data         = 'lib/data';
  const _presentation = 'lib/presentation';
  const _services     = 'lib/services';

  testArchGroup('Domain layer \u2014 isolated from all outer layers', () {
      testArch('Domain must not depend on the data layer', (arch) {
        final domainSelector = arch.classes(folder: _domain);

        expect(domainSelector, doesNotDependOn(_data));
      });

      testArch('Domain must not depend on the presentation layer', (arch) {
        final domainSelector = arch.classes(folder: _domain);

        expect(domainSelector, doesNotDependOn(_presentation));
      });

      testArch('Domain must be Flutter-agnostic', (arch) {
        final domainSelector = arch.classes(folder: _domain);

        expect(domainSelector, doesNotDependOnPackage('flutter'));
      });

      testArch('Domain must not use HTTP packages directly', (arch) {
        final domainSelector = arch.classes(folder: _domain);

        expect(domainSelector, doesNotDependOnPackage('dio'));
        expect(domainSelector, doesNotDependOnPackage('http'));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Presentation layer \u2014 must go through domain', () {
      testArch('Presentation must not access the data layer directly', (arch) {
        final presentationSelector = arch.classes(folder: _presentation);

        expect(presentationSelector, doesNotDependOn(_data));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Data layer \u2014 must not reach into presentation', () {
      testArch('Data layer must not depend on the presentation layer', (arch) {
        final dataSelector = arch.classes(folder: _data);

        expect(dataSelector, doesNotDependOn(_presentation));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository contract \u2014 interface in domain, impl in data', () {
      testArch('Repository interfaces in domain must be abstract', (arch) {
        final repositorySelector = arch.classes(folder: _domain, namePattern: r'.*Repository\$');

        expect(repositorySelector, isAbstractClass());
      });

      testArch('Repository implementations must not be abstract', (arch) {
        final repositoryImplSelector = arch.classes(namePattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, isConcreteClass());
      });

      testArch('Repository implementations must not access presentation', (arch) {
        final repositoryImplSelector = arch.classes(namePattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, doesNotDependOn(_presentation));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Use cases \u2014 single responsibility, pure Dart', () {
      testArch('Use cases must not depend on the data layer', (arch) {
        final useCaseSelector = arch.classes(namePattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOn(_data));
      });

      testArch('Use cases must not depend on the presentation layer', (arch) {
        final useCaseSelector = arch.classes(namePattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOn(_presentation));
      });

      testArch('Use cases must be Flutter-agnostic', (arch) {
        final useCaseSelector = arch.classes(namePattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOnPackage('flutter'));
      });

      testArch('Use cases must have at most 3 methods', (arch) {
        final useCaseSelector = arch.classes(namePattern: r'.*UseCase\$');

        expect(useCaseSelector, hasMaxMethods(3));
      }, severity: RuleSeverity.warning);
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Domain entities \u2014 immutable value objects', () {
      testArch('Domain entities must have all-final fields', (arch) {
        final entitySelector = arch.classes(folder: _domain, namePattern: r'.*Entity\$');

        expect(entitySelector, hasAllFinalFields());
      });

      testArch('Domain entities must not expose public mutable fields', (arch) {
        final entitySelector = arch.classes(folder: _domain, namePattern: r'.*Entity\$');

        expect(entitySelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository isolation \u2014 repos must not know each other', () {
      testArch('Repositories must not depend on other repositories', (arch) {
        final repositorySelector = arch.classes(namePattern: r'.*Repository\$');

        expect(repositorySelector, doesNotDependOn(_data));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Services layer \u2014 thin wrappers, no upstream dependencies', () {
      testArch('Services must not depend on the presentation layer', (arch) {
        final serviceSelector = arch.classes(folder: _services);

        expect(serviceSelector, doesNotDependOn(_presentation));
      });

      testArch('Services must not depend on repositories', (arch) {
        final serviceSelector = arch.classes(folder: _services);

        expect(serviceSelector, doesNotDependOn(_data));
      });

      testArch('Services must not depend on the domain layer', (arch) {
        final serviceSelector = arch.classes(folder: _services);

        expect(serviceSelector, doesNotDependOn(_domain));
      });

      testArch('Service classes must have all-final fields', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, hasAllFinalFields());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Data models \u2014 immutable DTOs', () {
      testArch('Data model classes must have all-final fields', (arch) {
        final modelSelector = arch.classes(folder: _data, namePattern: r'.*Model\$');

        expect(modelSelector, hasAllFinalFields());
      });

      testArch('Data models must not expose public mutable fields', (arch) {
        final modelSelector = arch.classes(folder: _data, namePattern: r'.*Model\$');

        expect(modelSelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.warning,
  );
}
''';
