import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:brew_master/core/models/package_dependencies.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class DependencyGraphView extends StatelessWidget {
  final PackageDependencies dependencies;
  const DependencyGraphView({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    final bool hasEdges = dependencies.dependencies.isNotEmpty || dependencies.dependents.isNotEmpty;

    // If there are no edges at all, prompt directly, more intuitive
    if (!hasEdges) {
      return Center(
        child: Text(AppLocalizations.of(context)!.depsNone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      );
    }

    final Graph graph = Graph()..isTree = false;
    final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 24
      ..levelSeparation = 40
      ..subtreeSeparation = 24
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;

    // Create node map
    final Map<String, Node> nodes = {};
    Node nodeFor(String name) => nodes.putIfAbsent(name, () => Node.Id(name));

    // Main package node
    final root = nodeFor(dependencies.packageName);
    graph.addNode(root); // Ensure at least one node, avoid GraphView children being empty

    // Dependencies as children
    for (final d in dependencies.dependencies) {
      final dn = nodeFor(d);
      graph.addEdge(root, dn);
    }

    // Dependents as incoming (draw as back edge)
    for (final r in dependencies.dependents) {
      final rn = nodeFor(r);
      graph.addEdge(rn, root);
    }

    Widget nodeWidget(String name) {
      final isRoot = name == dependencies.packageName;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isRoot ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.6)),
        ),
        child: Text(name, style: TextStyle(fontWeight: isRoot ? FontWeight.w700 : FontWeight.w500)),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.5,
      constrained: false,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
        builder: (Node n) => nodeWidget(n.key!.value as String),
      ),
    );
  }
}
