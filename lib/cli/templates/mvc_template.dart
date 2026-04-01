const List<({String fileName, String content})> mvcRuleFiles = [
  (fileName: 'mvc_test_arch.dart', content: _mvcArchTest),
];

const String _mvcArchTest = '''
import 'package:dartunit/dartunit.dart';

/// MVC Architecture rules.
///
/// Adjust the folder constants below to match your project structure.
void main() {

  const _models      = 'lib/models';
  const _views       = 'lib/views';
  const _controllers = 'lib/controllers';
  const _services    = 'lib/services';

  testArchGroup('Model layer \u2014 must not know about View or Controller', () {
      testArch('Models must not depend on controllers', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, doesNotDependOn(_controllers));
      });

      testArch('Models must not depend on views', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, doesNotDependOn(_views));
      });

      testArch('Models must be Flutter-agnostic', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, doesNotDependOnPackage('flutter'));
      }, severity: RuleSeverity.warning);
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('View layer \u2014 must communicate through Controller', () {
      testArch('Views must not access models directly', (arch) {
        final viewSelector = arch.classes(folder: _views);

        expect(viewSelector, doesNotDependOn(_models));
      });

      testArch('Views must not access services directly', (arch) {
        final viewSelector = arch.classes(folder: _views);

        expect(viewSelector, doesNotDependOn(_services));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Service layer \u2014 must be UI-agnostic', () {
      testArch('Services must not depend on views', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_views));
      });

      testArch('Services must not depend on controllers', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_controllers));
      });

      testArch('Services must not depend on models', (arch) {
        final serviceSelector = arch.classes(namePattern: r'.*Service\$');

        expect(serviceSelector, doesNotDependOn(_models));
      });
    },
    severity: RuleSeverity.error,
  );

  testArchGroup('Model immutability \u2014 explicit state changes via copyWith', () {
      testArch('Model classes must have all-final fields', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, hasAllFinalFields());
      });

      testArch('Model classes must not expose public mutable fields', (arch) {
        final modelSelector = arch.classes(folder: _models);

        expect(modelSelector, hasNoPublicFields());
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('Controller cohesion \u2014 avoid the massive controller', () {
      testArch('Controller classes must have at most 15 public methods', (arch) {
        final controllerSelector = arch.classes(namePattern: r'.*Controller\$');

        expect(controllerSelector, hasMaxMethods(15));
      });

      testArch('Controller classes must import at most 12 dependencies', (arch) {
        final controllerSelector = arch.classes(namePattern: r'.*Controller\$');

        expect(controllerSelector, hasMaxImports(12));
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('Controller isolation \u2014 no controller-to-controller dependencies', () {
      testArch('Controllers must not depend on other controllers', (arch) {
        final controllerSelector = arch.classes(namePattern: r'.*Controller\$');

        expect(controllerSelector, doesNotDependOn(_controllers));
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
}
''';
