const List<({String fileName, String content})> cleanRuleFiles = [
  (fileName: 'clean_arch_test.dart', content: _cleanArchTest),
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
      testArch('Domain must not depend on the data layer', (selector) {
        final domainSelector = selector.classes(inFolder: _domain);

        expect(domainSelector, doesNotDependOn(_data));
      });

      testArch('Domain must not depend on the presentation layer', (selector) {
        final domainSelector = selector.classes(inFolder: _domain);

        expect(domainSelector, doesNotDependOn(_presentation));
      });

      testArch('Domain must be Flutter-agnostic', (selector) {
        final domainSelector = selector.classes(inFolder: _domain);

        expect(domainSelector, doesNotDependOnPackage('flutter'));
      });

      testArch('Domain must not use HTTP packages directly', (selector) {
        final domainSelector = selector.classes(inFolder: _domain);

        expect(domainSelector, doesNotDependOnPackage('dio'));
        expect(domainSelector, doesNotDependOnPackage('http'));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Presentation layer \u2014 must go through domain', () {
      testArch('Presentation must not access the data layer directly', (selector) {
        final presentationSelector = selector.classes(inFolder: _presentation);

        expect(presentationSelector, doesNotDependOn(_data));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Data layer \u2014 must not reach into presentation', () {
      testArch('Data layer must not depend on the presentation layer', (selector) {
        final dataSelector = selector.classes(inFolder: _data);

        expect(dataSelector, doesNotDependOn(_presentation));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository contract \u2014 interface in domain, impl in data', () {
      testArch('Repository interfaces in domain must be abstract', (selector) {
        final repositorySelector = selector.classes(inFolder: _domain, matchingPattern: r'.*Repository\$');

        expect(repositorySelector, isAbstractClass());
      });

      testArch('Repository implementations must not be abstract', (selector) {
        final repositoryImplSelector = selector.classes(matchingPattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, isConcreteClass());
      });

      testArch('Repository implementations must not access presentation', (selector) {
        final repositoryImplSelector = selector.classes(matchingPattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, doesNotDependOn(_presentation));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Use cases \u2014 single responsibility, pure Dart', () {
      testArch('Use cases must not depend on the data layer', (selector) {
        final useCaseSelector = selector.classes(matchingPattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOn(_data));
      });

      testArch('Use cases must not depend on the presentation layer', (selector) {
        final useCaseSelector = selector.classes(matchingPattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOn(_presentation));
      });

      testArch('Use cases must be Flutter-agnostic', (selector) {
        final useCaseSelector = selector.classes(matchingPattern: r'.*UseCase\$');

        expect(useCaseSelector, doesNotDependOnPackage('flutter'));
      });

      testArch('Use cases must have at most 3 methods', (selector) {
        final useCaseSelector = selector.classes(matchingPattern: r'.*UseCase\$');

        expect(useCaseSelector, hasMaxMethods(3));
      }, severity: RuleSeverity.warning);
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Domain entities \u2014 immutable value objects', () {
      testArch('Domain entities must have all-final fields', (selector) {
        final entitySelector = selector.classes(inFolder: _domain, matchingPattern: r'.*Entity\$');

        expect(entitySelector, hasAllFinalFields());
      });

      testArch('Domain entities must not expose public mutable fields', (selector) {
        final entitySelector = selector.classes(inFolder: _domain, matchingPattern: r'.*Entity\$');

        expect(entitySelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Repository isolation \u2014 repos must not know each other', () {
      testArch('Repositories must not depend on other repositories', (selector) {
        final repositorySelector = selector.classes(matchingPattern: r'.*Repository\$');

        expect(repositorySelector, doesNotDependOn(_data));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Services layer \u2014 thin wrappers, no upstream dependencies', () {
      testArch('Services must not depend on the presentation layer', (selector) {
        final serviceSelector = selector.classes(inFolder: _services);

        expect(serviceSelector, doesNotDependOn(_presentation));
      });

      testArch('Services must not depend on repositories', (selector) {
        final serviceSelector = selector.classes(inFolder: _services);

        expect(serviceSelector, doesNotDependOn(_data));
      });

      testArch('Services must not depend on the domain layer', (selector) {
        final serviceSelector = selector.classes(inFolder: _services);

        expect(serviceSelector, doesNotDependOn(_domain));
      });

      testArch('Service classes must have all-final fields', (selector) {
        final serviceSelector = selector.classes(matchingPattern: r'.*Service\$');

        expect(serviceSelector, hasAllFinalFields());
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Data models \u2014 immutable DTOs', () {
      testArch('Data model classes must have all-final fields', (selector) {
        final modelSelector = selector.classes(inFolder: _data, matchingPattern: r'.*Model\$');

        expect(modelSelector, hasAllFinalFields());
      });

      testArch('Data models must not expose public mutable fields', (selector) {
        final modelSelector = selector.classes(inFolder: _data, matchingPattern: r'.*Model\$');

        expect(modelSelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.warning,
  );
}
''';
