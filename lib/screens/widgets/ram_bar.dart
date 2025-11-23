import 'package:flutter/material.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'ram_legend_item.dart';

class RamBar extends StatelessWidget {
  final double totalRamKb;
  final double usedRamKb; // Total used (System + Apps)
  final double appsRamKb; // Just Apps
  final double freeRamKb;

  const RamBar({
    super.key,
    required this.totalRamKb,
    required this.usedRamKb,
    required this.appsRamKb,
    required this.freeRamKb,
  });

  String _formatRam(double kb) {
    if (kb > 1024 * 1024) {
      return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (kb > 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate proportions
    // System RAM = Total Used - Apps RAM
    double systemRamKb = usedRamKb - appsRamKb;
    if (systemRamKb < 0) systemRamKb = 0; // Safety

    // Avoid division by zero
    if (totalRamKb <= 0) {
      return const SizedBox.shrink();
    }

    final double systemFlex = systemRamKb / totalRamKb;
    final double appsFlex = appsRamKb / totalRamKb;
    final double freeFlex = freeRamKb / totalRamKb;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.deviceMemory,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // The Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  // System (Dark Grey)
                  Expanded(
                    flex: (systemFlex * 1000).toInt(),
                    child: Container(color: Colors.grey[700]),
                  ),
                  // Apps (Light Blue)
                  Expanded(
                    flex: (appsFlex * 1000).toInt(),
                    child: Container(color: Colors.lightBlue[200]),
                  ),
                  // Free (Light Grey)
                  Expanded(
                    flex: (freeFlex * 1000).toInt(),
                    child: Container(color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          RamLegendItem(
            color: Colors.grey[700]!,
            label: AppLocalizations.of(context)!.system,
            value: _formatRam(systemRamKb),
          ),
          const SizedBox(height: 8),
          RamLegendItem(
            color: Colors.lightBlue[200]!,
            label: AppLocalizations.of(context)!.apps,
            value: _formatRam(appsRamKb),
          ),
          const SizedBox(height: 8),
          RamLegendItem(
            color: Colors.grey[300]!,
            label: AppLocalizations.of(context)!.free,
            value: _formatRam(freeRamKb),
          ),
        ],
      ),
    );
  }
}
