# dartunit — Documentação Completa

## O que é o dartunit?

**dartunit** é uma ferramenta de teste de arquitetura para projetos Dart/Flutter, inspirada no ArchUnit do ecossistema Java. Ela permite que você **defina regras arquiteturais no YAML** (ou em Dart) e as **execute automaticamente** contra o código-fonte, relatando violações com severidade, arquivo e linha.

**Problema que resolve:** Evitar que a arquitetura do projeto degrade com o tempo — ex: a camada de domínio importando a camada de dados, ou classes sem convenção de nomenclatura.

---

## Estrutura de Diretórios

```
dartunit/
├── bin/
│   └── dartunit.dart              # Ponto de entrada do executável CLI
├── lib/
│   ├── dartunit.dart              # Barrel export (API pública)
│   ├── cli/                       # Comandos CLI
│   │   ├── dartunit_cli.dart      # Root command runner
│   │   └── commands/
│   │       ├── init_command.dart     # dartunit init
│   │       ├── analyze_command.dart  # dartunit analyze
│   │       └── generate_command.dart # dartunit generate
│   ├── core/                      # Entidades do domínio da ferramenta
│   │   ├── entities/              # Abstrações principais
│   │   ├── predicates/            # Implementações de predicados
│   │   ├── selector/              # Implementações de seletores
│   │   ├── enums/                 # Enums (severity, predicate types, etc.)
│   │   └── extensions/            # Extensões Dart (factory dispatch)
│   ├── analyzer/                  # Análise do código-fonte alvo
│   │   ├── project_analyzer.dart  # Orquestrador da análise
│   │   ├── context/               # AnalysisContext
│   │   ├── models/                # AnalyzedClass, AnalyzedFile, etc.
│   │   ├── graph/                 # DependencyGraph (detecção de ciclos)
│   │   └── parsers/               # Regex parsers para imports e classes
│   ├── engine/                    # Motor de execução de regras
│   │   ├── rule_engine.dart       # Orquestrador
│   │   ├── rule_executor.dart     # Executa uma regra com isolamento de falha
│   │   └── custom_rule_loader.dart # Descobre regras customizadas
│   ├── presets/                   # Presets (templates de regras prontas)
│   │   ├── preset_expander.dart   # Despacha presets para implementações
│   │   └── *.dart                 # 12 presets built-in
│   ├── yaml/
│   │   └── yaml_rule_parser.dart  # Parseia dartunit.yaml em List<Rule>
│   └── reporter/
│       └── console_reporter.dart  # Exibe violações como tabela ASCII
└── test/                          # 54 testes automatizados
```

---

## Entidades Principais

### 1. `Rule` — A Regra

Entidade central. É **imutável** e combina um seletor + predicado.

```
Rule {
  id: "R001"
  description: "Domain must not depend on Data"
  severity: RuleSeverity.error
  selector: Selector           ← quem avaliar
  predicate: Predicate         ← qual condição verificar
}
```

`rule.evaluate(context)` percorre os subjects retornados pelo selector e executa o predicate em cada um, coletando violações.

---

### 2. `Selector` — Quem Avaliar

Define **quais elementos** do projeto serão submetidos ao predicado.

| Tipo | Classe | Filtra |
|---|---|---|
| `class` | `ClassSelector` | Classes por pasta, regex de nome, anotação, herança |
| `file` | `FileSelector` | Arquivos `.dart` por pasta ou regex de nome |
| `layer` | `LayerSelector` | Todas as classes de uma camada arquitetural |

**Filtros disponíveis no ClassSelector:**
- `folder` — pasta que o arquivo deve estar
- `namePattern` — regex aplicado ao nome da classe
- `annotatedWith` — nome da anotação que deve estar presente
- `extends` / `implements` — tipo pai/interface
- `excludeNames` — lista de nomes a ignorar

---

### 3. `Predicate` — A Condição

Define **qual propriedade** verificar em cada subject. Retorna `PredicateResult { passed: bool, message: String }`.

**Semântica positiva:** o predicado descreve uma condição que, quando verdadeira para um subject, **passa**. O framework reporta violação quando o predicado **falha**.

#### Predicados Atômicos

| Categoria | Predicado | O que verifica |
|---|---|---|
| **Dependência** | `DependOnFolderPredicate(folder)` | Classe importa de uma pasta |
| | `DependOnPackagePredicate(pkg)` | Classe importa de um pacote externo |
| | `OnlyDependOnFoldersPredicate([...])` | Importa apenas de pastas permitidas |
| | `MaxImportsPredicate(n)` | Número total de imports <= n |
| | `HasCircularDependencyPredicate()` | Participa de ciclo de dependência |
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
| **Métricas** | `MaxMethodsPredicate(n)` | Qtd métodos <= n |
| | `MaxFieldsPredicate(n)` | Qtd campos <= n |
| | `MinMethodsPredicate(n)` | Qtd métodos >= n |
| | `MinFieldsPredicate(n)` | Qtd campos >= n |
| **Campos** | `HasAllFinalFieldsPredicate()` | Todos campos são final |
| | `HasNoPublicFieldsPredicate()` | Sem campos públicos |
| **Métodos** | `HasMethodPredicate(name)` | Tem método com nome |
| | `HasNoPublicMethodsPredicate()` | Sem métodos públicos |
| **Conteúdo** | `FileContentMatchesPredicate(regex, desc)` | Arquivo contém padrão regex |

#### Predicados Compostos

```
NotPredicate(inner)          → passa quando inner FALHA
AndPredicate([a, b, c])      → passa quando TODOS passam (short-circuit)
OrPredicate([a, b, c])       → passa quando ALGUM passa (short-circuit)
```

**Caso crítico:** Para "classe NAO deve depender de lib/data":
```yaml
predicate:
  not:                            # NAO
    type: dependOnFolder          # depende de
    value: lib/data               # lib/data
```

---

### 4. `Preset` — Template de Regras Prontas

Presets são **fabricas de regras** para padrões comuns. Cada preset recebe configuração mínima e gera 1 ou mais `Rule` instâncias.

**12 Presets disponíveis:**

| ID do Preset | O que gera |
|---|---|
| `annotation/must-have` | Classes em pasta X devem ter anotação Y |
| `annotation/must-not-have` | Classes em pasta X não devem ter anotação Y |
| `layer/cannot-depend-on` | Camada A não pode importar de B (1 regra por target) |
| `layer/can-only-depend-on` | Camada A só pode importar de pastas permitidas |
| `layer/layered-architecture` | Arquitetura em camadas completa (N layers, N² regras) |
| `naming/folder-name-suffix` | Classes em `lib/service` devem terminar em `Service` |
| `naming/name-pattern` | Classes em pasta devem casar regex |
| `structure/must-be-abstract` | Classes em pasta devem ser abstratas |
| `structure/must-be-immutable` | Todos os campos devem ser final |
| `structure/no-circular-dependencies` | Proíbe qualquer ciclo de dependência |
| `structure/no-public-fields` | Sem campos públicos (sem `_`) |
| `metrics/class-size-limit` | Limite de métodos e/ou campos por classe |
| `dependency/no-external-package` | Proíbe uso de pacotes externos em pastas |
| `quality/no-banned-calls` | Proíbe padrões de texto nos arquivos (ex: `print(`) |

---

### 5. `Subject` — O Alvo da Avaliação

Wrapper uniforme para classes e arquivos. Carrega: `name`, `filePath`, `line`, e referência ao objeto analisado (`AnalyzedClass` ou `AnalyzedFile`).

---

### 6. `Violation` — A Violação

Registra uma única quebra de regra:

```
Violation {
  ruleId, ruleDescription, message,
  filePath, line, severity
}
```

---

### 7. `AnalysisContext` — O Resultado da Análise

Container imutável com tudo que o analisador descobriu:
- `classes` — todas as `AnalyzedClass`
- `files` — todos os `AnalyzedFile`
- `dependencyGraph` — grafo de importações (usado para detectar ciclos)
- `projectRoot` — raiz do projeto

---

## Camada de Análise (`lib/analyzer/`)

O `ProjectAnalyzer` lê todos os `.dart` dentro de `lib/` usando **regex** (não o compilador Dart), o que é rápido mas pode over-contar em casos extremos (código em string literals).

**Para cada arquivo:**
1. `ImportParser` extrai imports e exports
2. `ClassParser` extrai: nome, anotações, extends, implements, mixins, métodos, campos, isAbstract, isEnum, etc.
3. `DependencyGraph` registra aresta `(arquivo_A → arquivo_B)` para cada import

**`DependencyGraph`** suporta:
- Dependências diretas e transitivas
- Detecção de ciclos via DFS (`detectCycles()`)

---

## Engine de Execução

```
RuleEngine
  └→ para cada Rule:
       RuleExecutor.execute(rule, context)
         ├→ rule.selector.select(context)  → List<Subject>
         └→ para cada subject:
              rule.predicate.evaluate(subject)
                └→ se falhou → Violation
```

`RuleExecutor` isola falhas: se um predicado lançar exceção, gera violação sintética em vez de crashar a análise inteira.

---

## Comandos CLI

### `dartunit init`

Cria a estrutura `.dartunit/` no projeto alvo:

```
.dartunit/
├── dartunit.yaml          ← arquivo de configuração
├── README.md              ← documentação das regras
└── custom_rules/
    └── example_rule.dart  ← template de regra customizada
```

### `dartunit analyze [--path] [--config] [--no-color]`

Fluxo principal:
1. Carrega YAML → `List<Rule>`
2. Descobre custom rules em `.dartunit/custom_rules/`
3. Analisa código-fonte → `AnalysisContext`
4. Executa todas as regras → `List<Violation>`
5. Exibe tabela de violações no terminal
6. Sai com código `0` (ok), `1` (violações), `2` (erro de config)

### `dartunit generate RULE_NAME`

Cria scaffold de regra customizada:
- Gera `custom_rules/my_rule_name.dart` com classe implementando `CustomRule`
- Adiciona entrada comentada no `dartunit.yaml`

---

## Configuração YAML — Formato Completo

### Estrutura do arquivo

```yaml
rules:     # Regras declarativas diretas
  - ...

presets:   # Templates de regras prontas
  - ...
```

---

### Seção `rules:`

#### Regra básica

```yaml
- id: R001
  description: Domain must not depend on Data
  severity: error          # info | warning | error | critical
  selector:
    type: class            # class | file | layer
    where:
      folder: lib/domain
  predicate:
    not:
      type: dependOnFolder
      value: lib/data
```

#### Selector `class` — todos os filtros

```yaml
selector:
  type: class
  where:
    folder: lib/domain               # pasta (substring do path)
    namePattern: ".*RepositoryImpl$" # regex no nome da classe
    annotatedWith: injectable        # anotação presente
    extends: BaseEntity              # tipo pai
    implements: Repository           # interface
    excludeNames:                    # ignorar estes nomes
      - AbstractBase
```

#### Selector `file`

```yaml
selector:
  type: file
  where:
    folder: lib/data
    namePattern: ".*_test\\.dart$"
```

#### Selector `layer`

```yaml
selector:
  type: layer
  where:
    name: Domain
    folder: lib/domain
```

#### Predicados atômicos no YAML

```yaml
# Com value simples
predicate:
  type: nameEndsWith
  value: Service

# Com value numérico
predicate:
  type: maxMethods
  value: 20

# Sem value
predicate:
  type: hasAllFinalFields

# Com lista de values
predicate:
  type: onlyDependOnFolders
  value:
    - lib/domain
    - lib/shared
```

#### Predicados compostos no YAML

```yaml
# NOT
predicate:
  not:
    type: dependOnFolder
    value: lib/data

# AND
predicate:
  and:
    - type: nameEndsWith
      value: Service
    - not:
        type: dependOnFolder
        value: lib/ui

# OR
predicate:
  or:
    - type: nameEndsWith
      value: Bloc
    - type: nameEndsWith
      value: Cubit
```

---

### Seção `presets:`

#### `layer/layered-architecture` — o mais poderoso

```yaml
- preset: layer/layered-architecture
  severity: error
  exceptions: []
  layers:
    - name: Presentation
      folder: lib/presentation
      can_access:
        - lib/bloc
        - lib/domain
    - name: Bloc
      folder: lib/bloc
      can_access:
        - lib/domain
    - name: Domain
      folder: lib/domain
      can_access: []
    - name: Data
      folder: lib/data
      can_access:
        - lib/domain
```

Gera automaticamente regras para cada par de camadas onde o acesso não é permitido.

#### `naming/folder-name-suffix`

```yaml
- preset: naming/folder-name-suffix
  severity: error
  folders:
    - lib/bloc
    - lib/repository
  exceptions: []
# Classes em lib/bloc devem terminar em "Bloc"
# Classes em lib/repository devem terminar em "Repository"
```

#### `metrics/class-size-limit`

```yaml
- preset: metrics/class-size-limit
  severity: warning
  max_methods: 20
  max_fields: 10
  folders:
    - lib
  exceptions: []
```

#### `quality/no-banned-calls`

```yaml
- preset: quality/no-banned-calls
  severity: warning
  patterns:
    - 'print\s*\('
    - 'debugPrint\s*\('
  exclude_folders:
    - test
```

#### `structure/must-be-immutable`

```yaml
- preset: structure/must-be-immutable
  severity: error
  folders:
    - lib/domain/entities
  exceptions:
    - MutableEntity        # excecoes por nome de classe
```

---

## Fluxo Completo de Execução

```
dartunit analyze
       │
       ▼
AnalyzeCommand
  ├─ YamlRuleParser.parse("dartunit.yaml")
  │     ├─ Le secao "rules" → instancia Rule diretamente
  │     └─ Le secao "presets" → PresetExpander → expande em List<Rule>
  │
  ├─ CustomRuleLoader.discoverRuleFiles()
  │     └─ Lista .dart em .dartunit/custom_rules/
  │
  ├─ ProjectAnalyzer.analyze()
  │     ├─ Glob: descobre todos lib/**/*.dart
  │     ├─ ImportParser: extrai imports de cada arquivo
  │     ├─ ClassParser: extrai classes, metodos, campos
  │     ├─ DependencyGraph: constroi grafo de dependencias
  │     └─ → AnalysisContext
  │
  ├─ RuleEngine.evaluate(context)
  │     └─ Para cada Rule:
  │           RuleExecutor.execute()
  │             ├─ selector.select(context) → [Subject, ...]
  │             └─ Para cada Subject:
  │                   predicate.evaluate(subject)
  │                     └─ PredicateResult { passed, message }
  │                   → se !passed → Violation
  │
  └─ ConsoleReporter.report(violations)
        ├─ Tabela ASCII com colunas: Severity | Rule | File | Line | Message
        ├─ Cores por severidade (ansi_styles)
        └─ Sumario: X violations, Y errors
```

---

## Saídas e Severidades

| Severity | Significado | Causa falha? | Cor |
|---|---|---|---|
| `info` | Observação | Não | Branco |
| `warning` | Alerta | Não | Amarelo |
| `error` | Quebra de regra | **Sim** (exit 1) | Vermelho |
| `critical` | Violação crítica | **Sim** (exit 1) | Magenta |

---

## Regras Customizadas (Dart)

Para casos não cobertos pelo YAML, o usuário implementa `CustomRule`:

```dart
// .dartunit/custom_rules/no_god_classes.dart
class NoGodClasses implements CustomRule {
  @override
  String get id => 'CUSTOM_NO_GOD_CLASSES';

  @override
  String get description => 'Classes must not have more than 30 methods';

  @override
  Rule build() => Rule(
    id: id,
    description: description,
    severity: RuleSeverity.warning,
    selector: ClassSelector(),
    predicate: MaxMethodsPredicate(30),
  );
}
```

---

## Resumo em Uma Linha por Conceito

| Conceito | Papel |
|---|---|
| **Rule** | Une seletor + predicado + severidade |
| **Selector** | Filtra quais elementos analisar |
| **Predicate** | Define a condição a verificar |
| **Subject** | Um elemento sob análise (classe ou arquivo) |
| **Preset** | Template que gera múltiplas regras |
| **Violation** | Registro de uma quebra de regra |
| **AnalysisContext** | Snapshot do projeto analisado |
| **DependencyGraph** | Grafo de imports para análise de dependências |
| **RuleEngine** | Orquestra execução de todas as regras |
| **YamlRuleParser** | Converte YAML em `List<Rule>` |
| **ConsoleReporter** | Exibe violações formatadas no terminal |
