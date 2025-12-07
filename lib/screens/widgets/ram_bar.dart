import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:running_services_monitor/core/extensions.dart';
import 'package:running_services_monitor/utils/format_utils.dart';
import 'ram_legend_item.dart';

class RamBar extends StatelessWidget {
  final double totalRamKb;
  final double usedRamKb;
  final double freeRamKb;

  const RamBar({super.key, required this.totalRamKb, required this.usedRamKb, required this.freeRamKb});

  @override
  Widget build(BuildContext context) {
    if (totalRamKb <= 0) {
      return const SizedBox.shrink();
    }

    final double usedFlex = usedRamKb / totalRamKb;
    final double freeFlex = freeRamKb / totalRamKb;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.loc.deviceMemory,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.rSafe),
            child: SizedBox(
              height: 24.h,
              child: Row(
                children: [
                  Expanded(
                    flex: (usedFlex * 1000).toInt(),
                    child: Container(color: Colors.grey[700]),
                  ),
                  Expanded(
                    flex: (freeFlex * 1000).toInt(),
                    child: Container(color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          RamLegendItem(color: Colors.grey[700]!, label: context.loc.used, value: formatRam(usedRamKb)),
          SizedBox(height: 8.h),
          RamLegendItem(color: Colors.grey[300]!, label: context.loc.free, value: formatRam(freeRamKb)),
        ],
      ),
    );
  }
}
