# Test Plan — dartunit

## Objetivo

Bateria completa de testes unitários e de integração para o `dartunit`, cobrindo todos os **predicados** (31), todos os **presets** (14) e todos os **comandos CLI** (3).

---

## Estrutura

```
test/
├── helpers/
│   └── test_helpers.dart          # Fábrica compartilhada de fixtures
├── predicates/
│   ├── naming/                    # Predicados de nomenclatura (4)
│   ├── annotation/                # Predicados de anotação (2)
│   ├── inheritance/               # Predicados de herança (3)
│   ├── structure/                 # Predicados de estrutura de tipo (5)
│   ├── fields/                    # Predicados de campos (4)
│   ├── methods/                   # Predicados de métodos (4)
│   ├── dependencies/              # Predicados de dependência (4)
│   ├── content/                   # Predicados de conteúdo de arquivo (1)
│   ├── circular/                  # Predicados de ciclo (1)
│   └── composite/                 # Predicados compostos (3)
├── presets/                       # Testes de preset (14)
├── cli/                           # Testes de CLI (3 comandos)
└── README.md                      # Este arquivo
```

---

## Convenções de Teste

Cada arquivo de teste segue a estrutura:

```
group('<PredicateOrPreset>', () {
  // ── valid cases (passes) ──
  test('passes when ...');
  test('passes when ...');
  test('passes when ...');

  // ── fail cases ──
  test('fails when ...');
  test('fails when ...');
  test('fail message contains ...');
});
```

**Mínimo por item:** 3 casos válidos + 3 casos de falha.

---

## Predicados

### Nomenclatura (`predicates/naming/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `name_contains_predicate_test.dart` | `NameContainsPredicate` | contains substring, middle, full name; wrong case, wrong substring |
| `name_ends_with_predicate_test.dart` | `NameEndsWithPredicate` | suffix match, exact, same as name; no suffix, wrong position |
| `name_starts_with_predicate_test.dart` | `NameStartsWithPredicate` | prefix match, single-char, exact; wrong prefix, case mismatch |
| `name_matches_pattern_predicate_test.dart` | `NameMatchesPatternPredicate` | BLoC pattern, event pattern, literal; wrong pattern, anchored |

### Anotação (`predicates/annotation/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `annotated_with_predicate_test.dart` | `AnnotatedWithPredicate` | carries annotation, multi-annotations, single; no annotations, different ones |
| `not_annotated_with_predicate_test.dart` | `NotAnnotatedWithPredicate` | not carrying, other annotations; carries forbidden, among multiple |

### Herança (`predicates/inheritance/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `extends_predicate_test.dart` | `ExtendsPredicate` | extends match, Bloc, StatelessWidget; different extends, extends nothing |
| `implements_predicate_test.dart` | `ImplementsPredicate` | implements match, multi, single; no implements, different |
| `uses_mixin_predicate_test.dart` | `UsesMixinPredicate` | uses mixin, multi-mixin, single; no mixin, different mixins |

### Estrutura (`predicates/structure/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `is_abstract_predicate_test.dart` | `IsAbstractPredicate` | abstract class, use case, widget; concrete, enum |
| `is_enum_predicate_test.dart` | `IsEnumPredicate` | enum, PaymentMethod, Singleton; class, abstract class |
| `is_mixin_predicate_test.dart` | `IsMixinPredicate` | mixin, EquatableMixin, CachingMixin; class, abstract class |
| `is_extension_predicate_test.dart` | `IsExtensionPredicate` | extension, DateTimeExtension, ListExtension; class, mixin |
| `is_concrete_class_predicate_test.dart` | `IsConcreteClassPredicate` | concrete, with fields, plain; abstract, mixin, enum |

### Campos (`predicates/fields/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `has_all_final_fields_predicate_test.dart` | `HasAllFinalFieldsPredicate` | all final, all const, static mutable ok, no fields; mutable field, message, multiple mutable |
| `has_no_public_fields_predicate_test.dart` | `HasNoPublicFieldsPredicate` | all private, no fields, static public ok; public instance, message |
| `max_fields_predicate_test.dart` | `MaxFieldsPredicate` | below limit, at limit, zero fields; exceeds, message, limit=0 |
| `min_fields_predicate_test.dart` | `MinFieldsPredicate` | exceeds min, at min, min=0; below min, no fields when min=1, message |

### Métodos (`predicates/methods/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `has_method_predicate_test.dart` | `HasMethodPredicate` | method present, among many, private; no methods, different methods, message |
| `has_no_public_methods_predicate_test.dart` | `HasNoPublicMethodsPredicate` | all private, none, single private; public present, message excludes private |
| `max_methods_predicate_test.dart` | `MaxMethodsPredicate` | below limit, at limit, zero methods; exceeds, message, limit=0 |
| `min_methods_predicate_test.dart` | `MinMethodsPredicate` | exceeds min, at min, min=0; below min, no methods when min=1, message |

### Dependências (`predicates/dependencies/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `depend_on_folder_predicate_test.dart` | `DependOnFolderPredicate` | folder in import, one of many, pass message; no match, empty imports, fail message |
| `depend_on_package_predicate_test.dart` | `DependOnPackagePredicate` | package prefix match, multi-import, sub-path; no match, empty, message |
| `max_imports_predicate_test.dart` | `MaxImportsPredicate` | below limit, at limit, no imports; exceeds, message, limit=0 |
| `only_depend_on_folders_predicate_test.dart` | `OnlyDependOnFoldersPredicate` | all allowed, no imports, single allowed; forbidden import, message, none allowed |

### Conteúdo (`predicates/content/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `file_content_matches_predicate_test.dart` | `FileContentMatchesPredicate` | pattern found, multi-line, description in message; no match, unreadable file, message includes pattern |

### Ciclos (`predicates/circular/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `has_circular_dependency_predicate_test.dart` | `HasCircularDependencyPredicate` | A→B→A cycle, 3-node cycle, message includes path; no deps, DAG, not in cycle |

### Compostos (`predicates/composite/`)

| Arquivo | Predicado | Cobertura |
|---------|-----------|-----------|
| `not_predicate_test.dart` | `NotPredicate` | inner fails→passes, domain clean, no annotation; inner passes→fails, domain dirty, message reuses inner |
| `and_predicate_test.dart` | `AndPredicate` | all pass, single, three; first fails, last fails, message describes failure |
| `or_predicate_test.dart` | `OrPredicate` | first passes, last passes, second of two; none pass, single fails, message aggregates |

---

## Presets

Cada preset tem grupos para:
1. **Contrato** — `presetId`, quantidade de regras geradas, edge cases (empty config)
2. **Propriedades das regras** — selector.folder, severity default/override, exceptions
3. **Avaliação de predicado** — pelo menos 1 pass + 1 fail + 1 message check

| Arquivo | Preset ID |
|---------|-----------|
| `naming_class_suffix_preset_test.dart` | `naming/class-name-suffix` |
| `layer_cannot_depend_on_preset_test.dart` | `layer/cannot-depend-on` |
| `layer_can_only_depend_on_preset_test.dart` | `layer/can-only-depend-on` |
| `layer_layered_architecture_preset_test.dart` | `layer/layered-architecture` |
| `must_be_abstract_preset_test.dart` | `structure/must-be-abstract` |
| `must_be_immutable_preset_test.dart` | `structure/must-be-immutable` |
| `no_public_fields_preset_test.dart` | `structure/no-public-fields` |
| `no_circular_dependencies_preset_test.dart` | `structure/no-circular-dependencies` |
| `annotation_must_have_preset_test.dart` | `annotation/must-have` |
| `annotation_must_not_have_preset_test.dart` | `annotation/must-not-have` |
| `class_size_limit_preset_test.dart` | `metrics/class-size-limit` |
| `no_external_package_preset_test.dart` | `dependency/no-external-package` |
| `no_banned_calls_preset_test.dart` | `quality/no-banned-calls` |

---

## Comandos CLI

Os testes de CLI usam temp directories reais e o `DartunitCli` diretamente, sem mocks.

### `analyze` (`cli/analyze_command_test.dart`)

| Teste | Esperado |
|-------|----------|
| Config não encontrada | exit code 2 |
| Regras sem classes selecionadas | exit code 0 |
| Violação de nível `error` encontrada | exit code 1 |
| Apenas violações de `warning` | exit code 0 (warnings não falham) |
| Flag `--no-color` aceita | exit code 0 |
| Flag `--config` aponta para path customizado | exit code 0 |
| Preset configurado sem violações | exit code 0 |

### `init` (`cli/init_command_test.dart`)

| Teste | Verificação |
|-------|-------------|
| Execução bem-sucedida | exit code 0 |
| `dartunit.yaml` criado | file.existsSync() |
| `README.md` criado | file.existsSync() |
| `custom_rules/` criado | dir.existsSync() |
| `example_rule.dart` criado | file.existsSync() |
| Segunda execução (idempotência) | exit code 0, não sobrescreve |

### `generate` (`cli/generate_command_test.dart`)

| Teste | Verificação |
|-------|-------------|
| Execução bem-sucedida | exit code 0 |
| Arquivo `_rule.dart` criado | file.existsSync() |
| Entry adicionada ao `dartunit.yaml` | contains ruleId |
| snake_case → PascalCase | class name no conteúdo |
| Sem argumento de nome | exit code 2 |
| `.dartunit` inexistente | exit code 2 |

---

## Como Executar

```bash
# Todos os testes
cd D:/Documentos/teste/dartunit
dart test

# Apenas predicados
dart test test/predicates/

# Apenas presets
dart test test/presets/

# Apenas CLI
dart test test/cli/

# Arquivo específico
dart test test/predicates/composite/not_predicate_test.dart
```

---

## Cobertura

| Categoria | Arquivos | Casos |
|-----------|---------|-------|
| Predicados | 27 arquivos | ~180 casos |
| Presets | 14 arquivos | ~130 casos |
| CLI | 3 arquivos | ~20 casos |
| **Total** | **44 arquivos** | **~330 casos** |
