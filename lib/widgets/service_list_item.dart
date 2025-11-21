import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../models/service_info.dart';

class ServiceListItem extends StatelessWidget {
  final RunningServiceInfo service;

  const ServiceListItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildAppIcon(context),
        title: Text(service.appName ?? service.packageName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              service.packageName,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (service.ramUsage != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.memory, size: 12, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    service.ramUsage!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
            if (service.serviceClass != null) ...[
              const SizedBox(height: 2),
              Text(
                'Service: ${service.serviceClass}',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.numbers, size: 12, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'PID: ${service.pid}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Icon(
                  service.isSystemApp ? Icons.android : Icons.person,
                  size: 12,
                  color: service.isSystemApp
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  service.isSystemApp ? 'System' : 'User',
                  style: TextStyle(
                    fontSize: 11,
                    color: service.isSystemApp
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: () => _showServiceDetails(context),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return FutureBuilder<AppInfo?>(
      future: _getAppInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.icon != null) {
          return Image.memory(snapshot.data!.icon!, width: 40, height: 40);
        }
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            service.isSystemApp ? Icons.android : Icons.apps,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        );
      },
    );
  }

  Future<AppInfo?> _getAppInfo() async {
    try {
      // We use installed_apps here just to get the icon for this specific package
      // This is lazy loading - only happens when the item is built
      return await InstalledApps.getAppInfo(service.packageName);
    } catch (e) {
      return null;
    }
  }

  void _showServiceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.appName ?? service.packageName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Package', service.packageName),
              const SizedBox(height: 8),
              _buildDetailRow('Process', service.processName),
              const SizedBox(height: 8),
              _buildDetailRow('PID', service.pid.toString()),
              if (service.ramUsage != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('RAM Usage', service.ramUsage!),
              ],
              if (service.serviceClass != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Service Class', service.serviceClass!),
              ],
              const SizedBox(height: 8),
              _buildDetailRow('Type', service.isSystemApp ? 'System App' : 'User App'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        SelectableText(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
