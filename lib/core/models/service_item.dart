import 'package:flutter/foundation.dart';

enum ServiceStatus { started, stopped, error, unknown }

@immutable
class ServiceItem {
  final String name;
  final ServiceStatus status;
  final String? user;
  final String? filePath;

  const ServiceItem({
    required this.name,
    required this.status,
    this.user,
    this.filePath,
  });
} 