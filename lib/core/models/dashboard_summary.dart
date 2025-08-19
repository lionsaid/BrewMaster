class DashboardSummary {
  final int formulaeCount;
  final int casksCount;
  final int tapsCount;
  final int outdatedCount;
  final bool doctorHealthy;
  final String cleanupSizeText; // human readable, e.g., "1.2 GB"
  final int servicesRunning;
  final int servicesStoppedOrErrored;

  DashboardSummary({
    required this.formulaeCount,
    required this.casksCount,
    required this.tapsCount,
    required this.outdatedCount,
    required this.doctorHealthy,
    required this.cleanupSizeText,
    required this.servicesRunning,
    required this.servicesStoppedOrErrored,
  });
} 