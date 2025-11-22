import 'package:flutter/material.dart';

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
      return '${(kb / (1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (kb > 1024) {
      return '${(kb / 1024).toStringAsFixed(0)} MB';
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
          const Text('Device memory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
          _buildLegendItem(color: Colors.grey[700]!, label: 'System', value: _formatRam(systemRamKb)),
          const SizedBox(height: 8),
          _buildLegendItem(color: Colors.lightBlue[200]!, label: 'Apps', value: _formatRam(appsRamKb)),
          const SizedBox(height: 8),
          _buildLegendItem(color: Colors.grey[300]!, label: 'Free', value: _formatRam(freeRamKb)),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String value}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text('$value of RAM', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
