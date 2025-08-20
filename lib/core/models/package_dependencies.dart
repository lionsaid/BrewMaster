class PackageDependencies {
  final String packageName;
  final List<String> dependencies;
  final List<String> dependents;

  PackageDependencies({
    required this.packageName,
    this.dependencies = const [],
    this.dependents = const [],
  });

  factory PackageDependencies.empty(String packageName) {
    return PackageDependencies(packageName: packageName);
  }
}
