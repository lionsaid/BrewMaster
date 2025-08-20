import 'package:flutter/material.dart';
import 'package:brew_master/core/models/package.dart';
import 'package:brew_master/core/widgets/package_icon.dart';

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool selected;
  final VoidCallback? onToggleSelected;
  final VoidCallback? onUninstall;
  final VoidCallback? onReinstall;
  final VoidCallback? onOpenHomepage;
  final VoidCallback? onUpdate;

  const PackageListItem({
    super.key,
    required this.package,
    this.selected = false,
    this.onToggleSelected,
    this.onUninstall,
    this.onReinstall,
    this.onOpenHomepage,
    this.onUpdate, // Add onUpdate
  });

  bool _isDateString(String s) {
    try {
      DateTime.parse(s); // Attempt to parse as date
      return RegExp(r'^\d{4}[-/]?\d{2}[-/]?\d{2}$').hasMatch(s);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDateVersion = _isDateString(package.version);

    return InkWell(
      onTap: () { if (onToggleSelected != null) onToggleSelected!(); },
      onLongPress: () => onOpenHomepage?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (onToggleSelected != null)
              Checkbox(value: selected, onChanged: (_) => onToggleSelected?.call()),
            const SizedBox(width: 8),
            FaviconOrTypeIcon(isCask: package.isCask, homepage: package.homepage, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (package.description.isNotEmpty)
                    Text(
                      package.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(isDateVersion ? package.version : 'v${package.version}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            if (package.isOutdated) ...[
              const SizedBox(width: 8),
              const Icon(Icons.update, color: Colors.orange, size: 20),
            ],
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
