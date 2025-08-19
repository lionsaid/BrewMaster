class Package {
  final String name;
  final String fullName;
  final String description;
  final String version;
  final String homepage;
  final String license;
  final bool installed;
  final bool isCask;
  final bool isOutdated;

  Package({
    required this.name,
    required this.fullName,
    required this.description,
    required this.version,
    required this.homepage,
    required this.license,
    required this.installed,
    required this.isCask,
    this.isOutdated = false,
  });

// In lib/core/models/package.dart

// ... existing Package class definition ...

  factory Package.fromJson(Map<String, dynamic> json, {bool isCask = false}) {
    if (isCask) {
      // Handling for Casks
      return Package(
        name: json['token'],
        fullName: json['full_token'],
        description: json['desc'] ?? '',
        version: json['version'] ?? 'N/A',
        homepage: json['homepage'] ?? '',
        license: json['license'] ?? 'N/A',
        installed: json['installed'] != null,
        isCask: true,
        isOutdated: false, // Default for now, will be updated in PackagesView
      );
    } else {
      // Handling for Formulae
      return Package(
        name: json['name'],
        fullName: json['full_name'],
        description: json['desc'] ?? '',
        version: json['versions']['stable'],
        homepage: json['homepage'] ?? '',
        license: json['license'] ?? 'N/A',
        installed: (json['installed'] as List<dynamic>).isNotEmpty,
        isCask: false,
        isOutdated: false, // Default for now, will be updated in PackagesView
      );
    }
  }
// ... rest of the file
} 