class OutdatedPackage {
  final String name;
  final List<String> installedVersions;
  final String currentVersion;
  final bool isCask;

  OutdatedPackage({
    required this.name,
    required this.installedVersions,
    required this.currentVersion,
    required this.isCask,
  });

  factory OutdatedPackage.fromJson(Map<String, dynamic> json, {bool isCask = false}) {
    return OutdatedPackage(
      name: json['name'],
      installedVersions: List<String>.from(json['installed_versions']),
      currentVersion: json['current_version'],
      isCask: isCask,
    );
  }
} 