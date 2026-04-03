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
            { label: 'Rules (Rule)', slug: 'fundamentals/rules' },
            { label: 'Selectors (Selector)', slug: 'fundamentals/selectors' },
            { label: 'Predicates (Predicate)', slug: 'fundamentals/predicates' },
            { label: 'Presets', slug: 'fundamentals/presets' },
            { label: 'Subjects & Violations', slug: 'fundamentals/subjects-violations' },
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
          label: 'Built-in Presets',
          collapsed: true,
          items: [
            { label: 'layeredArchitecturePreset', slug: 'presets/layered-architecture' },
            { label: 'layerCannotDependOnPreset', slug: 'presets/layer-cannot-depend-on' },
            { label: 'layerCanOnlyDependOnPreset', slug: 'presets/layer-can-only-depend-on' },
            { label: 'namingFolderSuffixPreset', slug: 'presets/naming-folder-suffix' },
            { label: 'namingNamePatternPreset', slug: 'presets/naming-name-pattern' },
            { label: 'mustBeAbstractPreset', slug: 'presets/must-be-abstract' },
            { label: 'mustBeImmutablePreset', slug: 'presets/must-be-immutable' },
            { label: 'noCircularDependenciesPreset', slug: 'presets/no-circular-dependencies' },
            { label: 'classSizeLimitPreset', slug: 'presets/class-size-limit' },
            { label: 'noPublicFieldsPreset', slug: 'presets/no-public-fields' },
            { label: 'noBannedCallsPreset', slug: 'presets/no-banned-calls' },
            { label: 'noExternalPackagePreset', slug: 'presets/no-external-package' },
            { label: 'annotationMustHavePreset', slug: 'presets/annotation-must-have' },
            { label: 'annotationMustNotHavePreset', slug: 'presets/annotation-must-not-have' },
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
