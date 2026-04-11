// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  integrations: [
    starlight({
      title: 'DartUnit',
      description: 'Architecture testing tool for Dart/Flutter projects',
      defaultLocale: 'root',
      locales: {
        root: {
          label: 'English',
          lang: 'en',
        }
      },
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/CzR21/dartunit' },
      ],
      sidebar: [
        {
          label: 'Overview',
          items: [
            { label: 'Introduction', slug: 'overview/introduction' },
            { label: 'Quick Start', slug: 'overview/quickstart' },
            { label: 'Installation', slug: 'overview/installation' },
          ],
        },
        {
          label: 'Fundamentals',
          items: [
            { label: 'How It Works', slug: 'fundamentals/how-it-works' },
            { label: 'Rules', slug: 'fundamentals/rules' },
            { label: 'Selectors', slug: 'fundamentals/selectors' },
            { label: 'Predicates', slug: 'fundamentals/predicates' },
            { label: 'Presets', slug: 'fundamentals/presets' },
            { label: 'Subjects', slug: 'fundamentals/subjects' },
            { label: 'Violations', slug: 'fundamentals/violations' },
          ],
        },
        {
          label: 'CLI Commands',
          items: [
            { label: 'Overview', slug: 'cli/overview' },
            { label: 'dartunit init', slug: 'cli/init' },
            { label: 'dartunit analyze', slug: 'cli/analyze' },
            { label: 'dartunit generate', slug: 'cli/generate' },
            { label: 'dartunit log', slug: 'cli/log' },
          ],
        },
        {
          label: 'Predicates',
          collapsed: true,
          items: [
            {
              label: 'Dependency',
              items: [
                { label: 'dependsOn / doesNotDependOn', slug: 'predicates/depend-on-folder' },
                { label: 'dependsOnPackage / doesNotDependOnPackage', slug: 'predicates/depend-on-package' },
                { label: 'onlyDependsOnFolders', slug: 'predicates/only-depend-on-folders' },
                { label: 'hasNoCircularDependency', slug: 'predicates/has-circular-dependency' },
                { label: 'hasMaxImports', slug: 'predicates/max-imports' },
              ],
            },
            {
              label: 'Naming',
              items: [
                { label: 'nameStartsWith', slug: 'predicates/name-starts-with' },
                { label: 'nameEndsWith', slug: 'predicates/name-ends-with' },
                { label: 'nameContains', slug: 'predicates/name-contains' },
                { label: 'nameMatchesPattern', slug: 'predicates/name-matches-pattern' },
              ],
            },
            {
              label: 'Type',
              items: [
                { label: 'isAbstractClass', slug: 'predicates/is-abstract' },
                { label: 'isConcreteClass', slug: 'predicates/is-concrete-class' },
                { label: 'isEnumType', slug: 'predicates/is-enum' },
                { label: 'isMixinType', slug: 'predicates/is-mixin' },
                { label: 'isExtensionType', slug: 'predicates/is-extension' },
                { label: 'extendsClass', slug: 'predicates/extends' },
                { label: 'implementsInterface', slug: 'predicates/implements' },
                { label: 'usesMixin', slug: 'predicates/uses-mixin' },
              ],
            },
            {
              label: 'Annotations',
              items: [
                { label: 'hasAnnotation / doesNotHaveAnnotation', slug: 'predicates/annotated-with' },
              ],
            },
            {
              label: 'Metrics',
              items: [
                { label: 'hasMaxMethods', slug: 'predicates/max-methods' },
                { label: 'hasMinMethods', slug: 'predicates/min-methods' },
                { label: 'hasMaxFields', slug: 'predicates/max-fields' },
                { label: 'hasMinFields', slug: 'predicates/min-fields' },
              ],
            },
            {
              label: 'Quality & Structure',
              items: [
                { label: 'hasAllFinalFields', slug: 'predicates/has-all-final-fields' },
                { label: 'hasNoPublicFields', slug: 'predicates/has-no-public-fields' },
                { label: 'hasNoPublicMethods', slug: 'predicates/has-no-public-methods' },
                { label: 'hasMethod', slug: 'predicates/has-method' },
                { label: 'hasContent / hasNoContent', slug: 'predicates/file-content-matches' },
              ],
            },
            {
              label: 'Combining Matchers',
              items: [
                { label: 'NOT — doesNot / hasNo', slug: 'predicates/not' },
                { label: 'AND — multiple expect()', slug: 'predicates/and' },
                { label: 'OR — regex alternation', slug: 'predicates/or' },
              ],
            },
          ],
        },
        {
          label: 'Presets',
          collapsed: true,
          items: [
            {
              label: 'Layer',
              items: [
                { label: 'layeredArchitecture', slug: 'presets/layered-architecture' },
                { label: 'layerCannotDependOn', slug: 'presets/layer-cannot-depend-on' },
                { label: 'layerCanOnlyDependOn', slug: 'presets/layer-can-only-depend-on' },
              ],
            },
            {
              label: 'Naming',
              items: [
                { label: 'namingClassSuffix', slug: 'presets/naming-class-suffix' },
                { label: 'namingFileSuffix', slug: 'presets/naming-file-suffix' },
              ],
            },
            {
              label: 'Structure',
              items: [
                { label: 'mustBeAbstract', slug: 'presets/must-be-abstract' },
                { label: 'mustBeImmutable', slug: 'presets/must-be-immutable' },
                { label: 'noPublicFields', slug: 'presets/no-public-fields' },
                { label: 'noCircularDependencies', slug: 'presets/no-circular-dependencies' },
              ],
            },
            {
              label: 'Quality & Metrics',
              items: [
                { label: 'classSizeLimit', slug: 'presets/class-size-limit' },
                { label: 'noBannedCalls', slug: 'presets/no-banned-calls' },
                { label: 'noExternalPackage', slug: 'presets/no-external-package' },
              ],
            },
            {
              label: 'Annotations',
              items: [
                { label: 'annotationMustHave', slug: 'presets/annotation-must-have' },
                { label: 'annotationMustNotHave', slug: 'presets/annotation-must-not-have' },
              ],
            },
          ],
        },
        {
          label: 'Custom Rules',
          items: [
            { label: 'Creating Custom Rules', slug: 'custom-rules/creating' },
            { label: 'Reference API', slug: 'custom-rules/api' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'All Predicates', slug: 'reference/predicates' },
            { label: 'All Selectors', slug: 'reference/selectors' },
            { label: 'All Presets', slug: 'reference/presets' },
            { label: 'Severities', slug: 'reference/severity' },
            { label: 'Exit Codes', slug: 'reference/exit-codes' },
          ],
        },
      ],
      customCss: ['./src/styles/custom.css'],
    }),
  ],
});
