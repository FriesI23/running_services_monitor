import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'default_service_icon.dart';

class ServiceIcon extends StatelessWidget {
  final RunningServiceInfo service;
  final double size;

  const ServiceIcon({super.key, required this.service, this.size = 40});

  @override
  Widget build(BuildContext context) {
    if (service.icon != null && service.icon is Uint8List) {
      return Image.memory(
        service.icon as Uint8List,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => DefaultServiceIcon(service: service, size: size),
      );
    }

    return DefaultServiceIcon(service: service, size: size);
  }
}
