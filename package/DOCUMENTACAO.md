# dartunit — Documentação Completa

## O que é o dartunit?

**dartunit** é uma ferramenta de teste de arquitetura para projetos Dart/Flutter, inspirada no ArchUnit do ecossistema Java. As regras são escritas como **arquivos de teste Dart normais** em `test_arch/`, executadas com `dart test`, e os resultados são exibidos no console e salvos como HTML.

**Problema que resolve:** Evitar que a arquitetura degrade ao longo do tempo — ex.: camada de domínio importando dados, classes sem convenção de nomenclatura, ciclos de dependência.

---

## Estrutura de Diretórios

```
dartunit/
├── bin/
│   └── dartunit.dart                  # Ponto de entrada CLI
├── lib/
│   ├── dartunit.dart                  # Barrel export (API pública)
│   ├── cli/
│   │   ├── dartunit_cli.dart          # CommandRunner raiz
│   │   ├── commands/
│   │   │   ├── init_command.dart      # dartunit init
│   │   │   ├── analyze_command.dart   # dartunit analyze
│   │   │   ├── generate_command.dart  # dartunit generate
│   │   │   └── log_command.dart       # dartunit log
│   │   ├── templates/                 # Scaffolds de templates (bloc/clean/mvc/mvvm)
│   │   └── texts/                     # Strings exibidas no terminal
│   ├── runner/
│   │   ├── arch_runner.dart           # testArch + testArchGroup (+ parts)
│   │   ├── arch_tester.dart           # ArchTester + ArchSubject
│   │   └── arch_matchers.dart         # Funções matcher públicas
│   ├── core/
│   │   ├── entities/                  # Rule, Predicate, Selector, Violation, ArchMatcher…
│   │   ├── predicates/                # 25+ implementações de predicados
│   │   ├── selectors/                 # ClassSelector, FileSelector, LayerSelector
│   │   ├── enums/                     # RuleSeverity, ExitCode, ArchTemplate, ReportColumn…
│   │   └── extensions/                # StringTableFormat, ViolationListExtension
│   ├── analyzer/
│   │   ├── project_analyzer.dart      # Orquestrador da análise
│   │   ├── context/                   # AnalysisContext
│   │   ├── models/                    # AnalyzedClass, AnalyzedFile, AnalyzedMethod, AnalyzedField
│   │   ├── parsers/                   # ImportParser, ClassParser
│   │   └── graph/                     # DependencyGraph (detecção de ciclos via DFS)
│   ├── engine/
│   │   ├── rule_engine.dart           # Executa todas as regras
│   │   ├── rule_executor.dart         # Executa uma regra com isolamento de falha
│   │   ├── analysis_logger.dart       # Persiste histórico de runs em disco
│   │   └── custom_rule_loader.dart    # Descobre arquivos de regra customizados
│   ├── presets/                       # 14 fábricas de regras prontas
│   ├── reporter/
│   │   ├── console_reporter.dart      # Tabela colorida no terminal
│   │   ├── html_reporter.dart         # Relatório HTML em .dartunit/report.html
│   │   └── violation_summary.dart     # Linha de resumo (totais por severidade)
│   └── utils/                         # Helpers internos (ANSI, tabela, terminal, etc.)
└── test_arch/                         # Regras do usuário ficam aqui
    └── *_arch_test.dart
```

---

## Como as Regras Funcionam

As regras são arquivos Dart normais. O padrão central é:

```dart
// test_arch/domain_arch_test.dart
import 'package:dartunit/dartunit.dart';
import 'package:test/test.dart';

void main() => testArch('Domain must not depend on Data', (arch) {
  final domain = arch.classes(folder: 'lib/domain');
  expect(domain, doesNotDependOn('lib/data'));
});
```

`testArch` é análogo ao `testWidgets` do Flutter:
- Recebe uma descrição e um callback `(ArchTester arch) → void`
- `arch` fornece seletores que retornam `ArchSubject`
- `ArchSubject` é passado ao `expect` com um matcher de arquitetura

---

## Entidades Principais

### `Rule`

Combina seletor + predicado + severidade. É imutável.

```
Rule {
  description: "Domain must not depend on Data"
  severity:    RuleSeverity.error
  selector:    Selector  ← quem avaliar
  predicate:   Predicate ← qual condição verificar
  exceptions:  List<String>  ← caminhos isentos
}
```

---

### `Selector` — Quem Avaliar

| Classe | Filtra |
|--------|--------|
| `ClassSelector` | Classes por pasta, regex de nome, anotação, herança |
| `FileSelector` | Arquivos `.dart` por pasta, regex de nome, pastas excluídas |
| `LayerSelector` | Todas as classes de uma pasta de camada arquitetural |

---

### `Predicate` — A Condição

Retorna `PredicateResult { passed: bool, message: String }`.

**Semântica positiva:** o predicado descreve uma condição que, quando verdadeira, **passa**. Violação ocorre quando o predicado **falha**.

#### Predicados Atômicos

| Categoria | Predicado | O que verifica |
|-----------|-----------|----------------|
| **Dependência** | `DependOnFolderPredicate(folder)` | Importa de pasta |
| | `DependOnPackagePredicate(pkg)` | Importa de pacote externo |
| | `OnlyDependOnFoldersPredicate([...])` | Importa apenas de pastas permitidas |
| | `MaxImportsPredicate(n)` | Total de imports ≤ n |
| | `HasCircularDependencyPredicate()` | Participa de ciclo |
| **Nomenclatura** | `NameEndsWithPredicate(suffix)` | Nome termina com sufixo |
| | `NameStartsWithPredicate(prefix)` | Nome começa com prefixo |
| | `NameContainsPredicate(str)` | Nome contém substring |
| | `NameMatchesPatternPredicate(regex)` | Nome casa regex |
| **Anotação** | `AnnotatedWithPredicate(ann)` | Tem anotação |
| | `NotAnnotatedWithPredicate(ann)` | Não tem anotação |
| **Herança** | `ExtendsPredicate(type)` | Estende tipo |
| | `ImplementsPredicate(type)` | Implementa interface |
| | `UsesMixinPredicate(mixin)` | Usa mixin |
| **Estrutura** | `IsAbstractPredicate()` | É abstrata |
| | `IsEnumPredicate()` | É enum |
| | `IsMixinPredicate()` | É mixin |
| | `IsExtensionPredicate()` | É extension |
| | `IsConcreteClassPredicate()` | É classe concreta |
| **Métricas** | `MaxMethodsPredicate(n)` | Métodos ≤ n |
| | `MinMethodsPredicate(n)` | Métodos ≥ n |
| | `MaxFieldsPredicate(n)` | Campos ≤ n |
| | `MinFieldsPredicate(n)` | Campos ≥ n |
| **Campos** | `HasAllFinalFieldsPredicate()` | Todos os campos são `final` |
| | `HasNoPublicFieldsPredicate()` | Sem campos públicos |
| **Métodos** | `HasMethodPredicate(name)` | Tem método com nome |
| | `HasNoPublicMethodsPredicate()` | Sem métodos públicos |
| **Conteúdo** | `FileContentMatchesPredicate(regex)` | Arquivo contém padrão |

#### Predicados Compostos

```
NotPredicate(inner)        → passa quando inner FALHA
AndPredicate([a, b, c])    → passa quando TODOS passam
OrPredicate([a, b, c])     → passa quando ALGUM passa
```

---

### `ArchTester` — O Objeto do Callback

Fornecido pelo `testArch` / `testArchGroup`. Produz seletores:

```dart
arch.classes(folder: 'lib/domain')
arch.classes(suffix: 'Bloc', folder: 'lib/bloc')
arch.classes(prefix: 'Base', namePattern: r'.*Impl$')
arch.files(folder: 'lib/data')
arch.layer('Domain', folder: 'lib/domain')

// Todos aceitam exceptions:
arch.classes(folder: 'lib/ui', exceptions: ['lib/ui/legacy/'])
```

---

### `ArchSubject` — O Finder

O que é passado ao `expect`. Carrega: seletor, contexto de análise, severidade padrão, exceções e referência ao `ArchTester`.

---

### `ArchMatcher` — O Matcher

Implementa `Matcher` do `package:test`. Ao ser avaliado:
1. Cria uma `Rule` com o predicado e a severidade ativa
2. Chama `RuleExecutor.execute(rule, context)`
3. Se `DARTUNIT_PROTOCOL=1`, emite `DARTUNIT_RESULT:{...}` no stderr (JSON)
4. Registra falhas em `tester.failures`

---

### `testArch` e `testArchGroup`

```dart
// Teste simples — analisa o projeto de forma independente
void main() => testArch('descrição', (arch) {
  expect(arch.classes(folder: 'lib/ui'), doesNotDependOn('lib/data'));
}, severity: RuleSeverity.warning);

// Grupo — analisa uma vez, compartilha contexto entre todos os testes
void main() => testArchGroup('Naming', (arch) {
  testArch('Blocs', (arch) { ... });
  testArch('Repos', (arch) { ... });
}, severity: RuleSeverity.error);
```

`testArchGroup` analisa o projeto uma única vez e injeta o mesmo `AnalysisContext` em todos os `testArch` filhos via `Zone`.

---

### `Violation`

```
Violation {
  ruleDescription, message,
  filePath, line, severity
}
```

---

### `AnalysisContext`

Container imutável com tudo que o analisador encontrou:
- `classes` — todas as `AnalyzedClass`
- `files` — todos os `AnalyzedFile`
- `dependencyGraph` — grafo de importações
- `projectRoot` — raiz do projeto

---

## Camada de Análise (`lib/analyzer/`)

`ProjectAnalyzer` lê todos os `.dart` dentro de `lib/` via **regex** (não o compilador Dart).

**Para cada arquivo:**
1. `ImportParser` extrai imports/exports
2. `ClassParser` extrai: nome, anotações, extends, implements, mixins, métodos, campos, isAbstract, isEnum, etc.
3. `DependencyGraph` registra aresta `(arquivo_A → arquivo_B)` para cada import

**`DependencyGraph`** suporta dependências diretas, transitivas e detecção de ciclos via DFS.

---

## Engine de Execução

```
RuleExecutor.execute(rule, context)
  ├─ rule.selector.select(context)  →  List<Subject>
  └─ para cada subject:
       rule.predicate.evaluate(subject)
         └─ se falhou → Violation
```

`RuleExecutor` isola falhas: se um predicado lançar exceção, gera violação sintética.

---

## Comandos CLI

### `dartunit init`

Cria `test_arch/` no projeto alvo com uma regra de exemplo.

```bash
dartunit init
dartunit init --template clean   # scaffold com template pré-definido
```

Templates disponíveis: `bloc`, `clean`, `mvc`, `mvvm`

### `dartunit analyze [--path] [--no-color]`

Fluxo completo:
1. Descobre todos os `*_arch_test.dart` em `test_arch/`
2. Executa `dart test <arquivos> --reporter json` como subprocesso
3. Coleta resultados via `DARTUNIT_RESULT:{...}` no stderr
4. Exibe tabela de violações no console
5. Salva histórico em `.dartunit/log.json`
6. Gera relatório HTML em `.dartunit/report.html`
7. Sai com código `0` (ok), `1` (violações), `2` (erro)

### `dartunit generate <nome>`

Cria `test_arch/<nome>_arch_test.dart` com template pronto para implementar.

### `dartunit log [--no-color]`

Exibe o histórico dos últimos runs salvos em `.dartunit/log.json`.

---

## Protocolo de Comunicação (DARTUNIT_PROTOCOL)

Quando `analyze` executa `dart test`, injeta `DARTUNIT_PROTOCOL=1` no ambiente.  
`ArchMatcher` detecta isso e emite no stderr:

```
DARTUNIT_RESULT:{"violations":[{"ruleDescription":"...","message":"...","filePath":"...","severity":"error","line":42}]}
```

O processo pai parseia essas linhas e reconstrói as `Violation`s.

---

## Severidades

| Severity | Label | Falha build? | Cor |
|----------|-------|-------------|-----|
| `info` | INFO | Não | Ciano |
| `warning` | WARN | Não | Amarelo |
| `error` | ERR | **Sim** (exit 1) | Vermelho |
| `critical` | CRIT | **Sim** (exit 1) | Magenta |

---

## Fluxo Completo de Execução

```
dartunit analyze
       │
       ▼
AnalyzeCommand
  ├─ Descobre *_arch_test.dart em test_arch/
  │
  ├─ Process.run('dart test <arquivos> --reporter json')
  │     env: DARTUNIT_PROTOCOL=1
  │
  │   [subprocesso: dart test]
  │     └─ testArch / testArchGroup
  │           ├─ ProjectAnalyzer.analyze()  →  AnalysisContext
  │           ├─ ArchTester.classes/files/layer  →  ArchSubject
  │           └─ expect(subject, matcher)
  │                 └─ ArchMatcher
  │                       ├─ RuleExecutor.execute()  →  List<Violation>
  │                       └─ stderr: "DARTUNIT_RESULT:{...}"
  │
  ├─ Parseia DARTUNIT_RESULT do stderr  →  List<Violation>
  │
  ├─ ConsoleReporter.report(violations)
  │     ├─ Tabela: Severity | Rule | File | Line | Message
  │     └─ Resumo: X violations · Y error(s) · Z warning(s)
  │
  ├─ AnalysisLogger.save(violations)  →  .dartunit/log.json
  └─ HtmlReporter.generate()  →  .dartunit/report.html
```

---

## Presets (14 fábricas)

| Preset | O que gera |
|--------|-----------|
| `namingClassSuffix` | Classes em pasta X devem terminar com sufixo Y |
| `mustBeAbstract` | Classes em pasta devem ser abstratas |
| `mustBeImmutable` | Todos os campos devem ser `final` |
| `noPublicFields` | Sem campos públicos |
| `noCircularDependencies` | Proíbe qualquer ciclo |
| `layerCannotDependOn` | Camada A não pode importar de B |
| `layerCanOnlyDependOn` | Camada A só pode importar de pastas permitidas |
| `layeredArchitecture` | Arquitetura em camadas completa (N² regras) |
| `annotationMustHave` | Classes em pasta X devem ter anotação Y |
| `annotationMustNotHave` | Classes em pasta X não devem ter anotação Y |
| `classSizeLimit` | Limite de métodos e/ou campos por classe |
| `noExternalPackage` | Proíbe uso de pacotes externos em pastas |
| `noBannedCalls` | Proíbe padrões de texto nos arquivos (ex: `print(`) |

---

## Resumo por Conceito

| Conceito | Papel |
|----------|-------|
| **`testArch`** | Registra um teste de arquitetura (análogo ao `testWidgets`) |
| **`testArchGroup`** | Agrupa testes com contexto compartilhado |
| **`ArchTester`** | Fornece seletores no callback do teste |
| **`ArchSubject`** | Resultado de um seletor — passado ao `expect` |
| **Matcher** | Ex.: `doesNotDependOn`, `nameEndsWith` — define a condição |
| **`ArchMatcher`** | Implementação interna do Matcher; chama `RuleExecutor` |
| **`Rule`** | Une seletor + predicado + severidade |
| **`Selector`** | Filtra quais elementos analisar |
| **`Predicate`** | Define a condição a verificar |
| **`Violation`** | Registro de uma quebra de regra |
| **`AnalysisContext`** | Snapshot do projeto analisado |
| **`DependencyGraph`** | Grafo de imports para análise de dependências |
| **`RuleExecutor`** | Executa uma regra com isolamento de falha |
| **`AnalysisLogger`** | Persiste histórico de runs em `.dartunit/log.json` |
| **`ConsoleReporter`** | Exibe violações como tabela colorida no terminal |
| **`HtmlReporter`** | Gera relatório HTML em `.dartunit/report.html` |
