const List<({String fileName, String content})> blocRuleFiles = [
  (fileName: 'bloc_test_arch.dart', content: _blocArchTest),
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
      testArch('Presentation widgets must not import from the data layer', (arch) {
        final presentationSelector = arch.classes(folder: presentation);

        expect(presentationSelector, doesNotDependOn(data));
      });
    },
  );

  testArchGroup('Data layer \u2014 must not reach back into presentation', () {
      testArch('Data layer must not depend on the presentation layer', (arch) {
        final dataSelector = arch.classes(folder: data);

        expect(dataSelector, doesNotDependOn(presentation));
      });

      testArch('Data layer must not depend on the BLoC layer', (arch) {
        final dataSelector = arch.classes(folder: data);

        expect(dataSelector, doesNotDependOn(blocs));
      });
    },
  );

  testArchGroup('Repository pattern \u2014 interface vs implementation', () {
      testArch('Repository interfaces must be abstract', (arch) {
        final repositorySelector = arch.classes(namePattern: r'.*Repository\$');

        expect(repositorySelector, isAbstractClass());
      });

      testArch('Repository implementations must not be abstract', (arch) {
        final repositoryImplSelector = arch.classes(namePattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, isConcreteClass());
      });

      testArch('Repository implementations must not import from presentation', (arch) {
        final repositoryImplSelector = arch.classes(namePattern: r'.*RepositoryImpl\$');

        expect(repositoryImplSelector, doesNotDependOn(presentation));
      });
    },
  );

  testArchGroup('State and Event immutability', () {
      testArch('BLoC State classes must have all-final fields', (arch) {
        final stateSelector = arch.classes(namePattern: r'.*State\$');

        expect(stateSelector, hasAllFinalFields());
      });

      testArch('BLoC Event classes must have all-final fields', (arch) {
        final eventSelector = arch.classes(namePattern: r'.*Event\$');

        expect(eventSelector, hasAllFinalFields());
      });
    },
  );

  testArchGroup('Data models \u2014 immutable DTOs', () {
      testArch('Data model classes must have all-final fields', (arch) {
        final modelSelector = arch.classes(folder: data, namePattern: r'.*Model\$');

        expect(modelSelector, hasAllFinalFields());
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('Coupling limits \u2014 prevent god-object BLoCs', () {
      testArch('BLoC classes must import at most 15 dependencies', (arch) {
        final blocSelector = arch.classes(namePattern: r'.*Bloc\$');

        expect(blocSelector, hasMaxImports(15));
      });

      testArch('Cubit classes must import at most 15 dependencies', (arch) {
        final cubitSelector = arch.classes(namePattern: r'.*Cubit\$');

        expect(cubitSelector, hasMaxImports(15));
      });
    },
    severity: RuleSeverity.warning,
  );

  testArchGroup('BLoC isolation \u2014 no bloc-to-bloc dependencies', () {
      testArch('BLoC classes must not depend on other BLoC classes', (arch) {
        final blocSelector = arch.classes(namePattern: r'.*Bloc\$');

        expect(blocSelector, doesNotDependOn(blocs));
      });

      testArch('Cubit classes must not depend on other BLoC classes', (arch) {
        final cubitSelector = arch.classes(namePattern: r'.*Cubit\$');

        expect(cubitSelector, doesNotDependOn(blocs));
      });
    },
    severity: RuleSeverity.critical,
  );
}
''';