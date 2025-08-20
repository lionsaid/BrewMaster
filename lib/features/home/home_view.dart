import 'dart:ui' show ImageFilter;
import 'package:brew_master/features/dashboard/dashboard_view.dart';
import 'package:brew_master/features/packages/packages_view.dart';
import 'package:brew_master/features/services/services_view.dart';
import 'package:brew_master/features/updates/updates_view.dart';
import 'package:flutter/material.dart';
import '../search/discover_view.dart';
import '../health/health_view.dart';
import '../recommend/recommend_view.dart';
import '../cleanup/cleanup_view.dart';
import 'settings_view.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.initialIndex = 0, this.packagesInitialFilter});
  final int initialIndex;
  final String? packagesInitialFilter; // 'all' | 'formulae' | 'casks'

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _index = widget.initialIndex;
  final GlobalKey<DashboardViewState> _dashKey = GlobalKey<DashboardViewState>();

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _onTabChanged(int i) {
    setState(() => _index = i);
    if (i == 0) {
      _dashKey.currentState?.reload();
    }
  }

  void _openHealth() {
    _onTabChanged(6);
  }

  void _goInstalled(BuildContext context, {String filter = 'all'}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeView(initialIndex: 1))).then((_) {});
    // When already inside HomeView with tabs, we want to open PackagesView with filter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final wide = width >= 960; // 更宽时显示标签
            final tint = Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.28)
                : Colors.white.withOpacity(0.38);
            final brand = const Color(0xFF5865F2);
            return Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: tint,
                    child: Stack(
                      children: [
                        NavigationRail(
                        // 更宽时扩展为带文字；窄时仅图标
                        extended: wide,
                        backgroundColor: Colors.transparent,
                        minExtendedWidth: wide ? 220 : 180,
                        selectedIndex: _index,
                        onDestinationSelected: _onTabChanged,
                        labelType: wide ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
                        // 选中 pill 指示器
                        indicatorColor: brand.withOpacity(0.14),
                        indicatorShape: const StadiumBorder(),
                          destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.dashboard_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.dashboard, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabDashboard),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.list_alt_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.list_alt, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabInstalled),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.apps_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.apps, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabDiscover),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.star_border, color: Colors.blue),
                            selectedIcon: Icon(Icons.star, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabRecommend),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.system_update_alt_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.system_update_alt, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabUpdates),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.miscellaneous_services_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.miscellaneous_services, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabServices),
                          ), NavigationRailDestination(
                            icon: const Icon(Icons.design_services_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.design_services, color: brand),
                            label: Text(AppLocalizations.of(context)!.healthTitle),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.cleaning_services, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabCleanup),
                          ), NavigationRailDestination(
                            icon: const Icon(Icons.settings_outlined, color: Colors.blue),
                            selectedIcon: Icon(Icons.settings, color: brand),
                            label: Text(AppLocalizations.of(context)!.tabSettings),
                          ),
                        ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.25)
                                    : Colors.white.withOpacity(0.45)),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
                          ),
                          child: IndexedStack(
                            index: _index,
                            children: [
                              DashboardView(key: _dashKey, onOpenHealth: _openHealth),
                              PackagesView(initialFilter: widget.packagesInitialFilter ?? 'all'),
                              const DiscoverView(),
                              const RecommendView(),
                              const UpdatesView(),
                              const ServicesView(),
                              const HealthView(),
                              const CleanupView(),
                              const SettingsView(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 