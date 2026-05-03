const List<({String fileName, String content})> blocRuleFiles = [
  (fileName: 'bloc_arch_test.dart', content: _blocArchTest),
];

const String _blocArchTest = '''
import 'package:dartunit/dartunit.dart';

/// BLoC Architecture rules.
/// Reference: https://bloclibrary.dev/architecture/
///
/// Adjust the folder constants below to match your project structure.
void main() {

  final String presentation = 'lib/presentation';
  final String blocs = 'lib/blocs';
  final String data = 'lib/data';

  testArchGroup('Presentation layer \u2014 must not access data directly', () {
      testArch('Presentation widgets must not import from the data layer', (selector) {
        final presentationSelector = selector.classes(inFolder: presentation);

        expect(presentationSelector, doesNotDependOn(data));
      });
    },
  );

  testArchGroup('Data layer \u2014 must not reach back into presentation', () {
      testArch('Data layer must not depend on the presentation layer', (selector) {
        final dataSelector = selector.classes(inFolder: data);

        expect(dataSelector, doesNotDependOn(presentation));
      });

      testArch('Data layer must not depend on the BLoC layer', (selector) {
        final dataSelector = selector.classes(inFolder: data);

        expect(dataSelector, doesNotDependOn(blocs));
      });
    },
  );

  testArchGroup('Repository pattern \u2014 interface vs implementation', () {
      testArch('Repository interfaces must be abstract', (selector) {
        final repositorySelector = selector.classes(matchingPattern: r'.*Repository\$');

        expect(repositorySelector, isAbstractClass());
      });

      testArch('Repository implementations must not be abstract', (selector) {
        final repositoryImplSelector = selector.classes(matchingPattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, isConcreteClass());
      });

      testArch('Repository implementations must not import from presentation', (selector) {
        final repositoryImplSelector = selector.classes(matchingPattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, doesNotDependOn(presentation));
      });
    },
  );

  testArchGroup('State and Event immutability', () {
      testArch('BLoC State classes must have all-final fields', (selector) {
        final stateSelector = selector.classes(matchingPattern: r'.*State\$');

        expect(stateSelector, hasAllFinalFields());
      });

      testArch('BLoC Event classes must have all-final fields', (selector) {
        final eventSelector = selector.classes(matchingPattern: r'.*Event\$');

        expect(eventSelector, hasAllFinalFields());
      });
    },
  );

  testArchGroup('Data models \u2014 immutable DTOs', () {
      testArch('Data model classes must have all-final fields', (selector) {
        final modelSelector = selector.classes(inFolder: data, matchingPattern: r'.*Model\$');

        expect(modelSelector, hasAllFinalFields());
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('Coupling limits \u2014 prevent god-object BLoCs', () {
      testArch('BLoC classes must import at most 15 dependencies', (selector) {
        final blocSelector = selector.classes(matchingPattern: r'.*Bloc\$');

        expect(blocSelector, hasMaxImports(15));
      });

      testArch('Cubit classes must import at most 15 dependencies', (selector) {
        final cubitSelector = selector.classes(matchingPattern: r'.*Cubit\$');

        expect(cubitSelector, hasMaxImports(15));
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('BLoC isolation \u2014 no bloc-to-bloc dependencies', () {
      testArch('BLoC classes must not depend on other BLoC classes', (selector) {
        final blocSelector = selector.classes(matchingPattern: r'.*Bloc\$');

        expect(blocSelector, doesNotDependOn(blocs));
      });

      testArch('Cubit classes must not depend on other BLoC classes', (selector) {
        final cubitSelector = selector.classes(matchingPattern: r'.*Cubit\$');

        expect(cubitSelector, doesNotDependOn(blocs));
      });
    },
    severity: RuleSeverity.critical,
  );
}
''';