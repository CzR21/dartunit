/// Represents a directed dependency graph between Dart files.
///
/// Nodes are file paths; edges represent import dependencies.
class DependencyGraph {
  final Map<String, Set<String>> _adjacency = {};
  final Map<String, Set<String>> _reverseAdjacency = {};

  /// Adds a directed edge from [from] to [to] (i.e., [from] imports [to]).
  void addEdge(String from, String to) {
    _adjacency.putIfAbsent(from, () => {}).add(to);
    _reverseAdjacency.putIfAbsent(to, () => {}).add(from);
    // Ensure both nodes exist in the graph.
    _adjacency.putIfAbsent(to, () => {});
    _reverseAdjacency.putIfAbsent(from, () => {});
  }

  /// Returns all files that [filePath] directly imports.
  Set<String> dependenciesOf(String filePath) =>
      _adjacency[filePath] ?? {};

  /// Returns all files that import [filePath].
  Set<String> dependentsOf(String filePath) =>
      _reverseAdjacency[filePath] ?? {};

  /// Returns all nodes in the graph.
  Set<String> get allNodes => _adjacency.keys.toSet();

  /// Returns all files that [filePath] depends on, directly or transitively.
  Set<String> transitiveDependenciesOf(String filePath) {
    final visited = <String>{};
    final queue = [filePath];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (visited.contains(current)) continue;
      visited.add(current);
      queue.addAll(_adjacency[current] ?? {});
    }

    visited.remove(filePath);
    return visited;
  }

  /// Detects all cyclic dependency chains in the graph.
  ///
  /// Returns a list of cycles, where each cycle is a list of file paths.
  List<List<String>> detectCycles() {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final stack = <String>[];
    final onStack = <String>{};

    void dfs(String node) {
      visited.add(node);
      stack.add(node);
      onStack.add(node);

      for (final neighbor in _adjacency[node] ?? {}) {
        if (!visited.contains(neighbor)) {
          dfs(neighbor);
        } else if (onStack.contains(neighbor)) {
          // Found a cycle — extract it from the stack.
          final cycleStart = stack.indexOf(neighbor);
          cycles.add(List.from(stack.sublist(cycleStart)));
        }
      }

      stack.removeLast();
      onStack.remove(node);
    }

    for (final node in _adjacency.keys) {
      if (!visited.contains(node)) {
        dfs(node);
      }
    }

    return cycles;
  }

  /// Returns true if [from] has a transitive dependency on [to].
  bool hasDependency(String from, String to) =>
      transitiveDependenciesOf(from).contains(to);

  @override
  String toString() {
    final buf = StringBuffer('DependencyGraph {\n');
    for (final entry in _adjacency.entries) {
      if (entry.value.isNotEmpty) {
        buf.writeln('  ${entry.key} -> ${entry.value.join(', ')}');
      }
    }
    buf.write('}');
    return buf.toString();
  }
}
