import 'package:flutter/material.dart';
import '../models/service_info.dart';

class AppDetailsScreen extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppDetailsScreen({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final processCount = appInfo.pids.length;
    final serviceCount = appInfo.services.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Running app')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildAppIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appInfo.appName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        '$processCount process and $serviceCount services',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(appInfo.totalRam, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'This app can\'t safely be stopped. If you stop it, you may lose some of your current work.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Service List (Optional, to preserve info)
            Text('Active Services', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: appInfo.services.length,
                itemBuilder: (context, index) {
                  final service = appInfo.services[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(service.serviceName),
                    subtitle: Text('PID: ${service.pid}'),
                    trailing: Text(service.ramUsage ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    if (appInfo.appInfo != null && appInfo.appInfo!.icon != null) {
      return Image.memory(appInfo.appInfo!.icon!, width: 48, height: 48);
    }
    return const Icon(Icons.android, size: 48);
  }
}
