import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/core/extensions.dart';

class RamInfoDialog extends StatelessWidget {
  final AppProcessInfo appInfo;

  const RamInfoDialog({super.key, required this.appInfo});

  String _formatRam(double kb) {
    if (kb <= 0) {
      return 'N/A';
    }
    if (kb > 1024 * 1024) {
      return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (kb > 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(0)} KB';
  }

  String _formatRawKb(double kb) {
    final kbInt = kb.toInt();
    final formatted = kbInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '${formatted}K';
  }

  String _getSourceLabel(String source) {
    switch (source) {
      case 'pid':
        return 'PID';
      case 'process_name':
        return 'Process';
      case 'lru':
        return 'LRU Process';
      default:
        return source;
    }
  }

  String _getRawDataLine(RamSourceInfo source) {
    final ramStr = _formatRawKb(source.ramKb);
    if (source.processName != null) {
      if (source.pid != null) {
        return '$ramStr: ${source.processName} (pid ${source.pid})';
      }
      return '$ramStr: ${source.processName}';
    } else if (source.pid != null) {
      return '$ramStr: ${appInfo.packageName} (pid ${source.pid})';
    }
    return '$ramStr: ${appInfo.packageName}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final verifyCommand = 'adb shell dumpsys meminfo | grep "${appInfo.packageName}"';

    return AlertDialog(
      title: Text(loc.ramCalculation, style: TextStyle(fontSize: 18.sp)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.rSafe),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.totalRam,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    appInfo.totalRam,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            if (appInfo.ramSources.isEmpty)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.rSafe),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        loc.noRamDataAvailable,
                        style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                loc.ramSources,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              ...appInfo.ramSources.map(
                (source) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.rSafe),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4.rSafe),
                            ),
                            child: Text(
                              _getSourceLabel(source.source),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              source.pid != null ? 'PID ${source.pid}' : source.processName ?? '-',
                              style: TextStyle(fontSize: 12.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatRam(source.ramKb),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.rSafe),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: SelectableText(
                          _getRawDataLine(source),
                          style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Text(
              loc.verifyCommand,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.rSafe),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          verifyCommand,
                          style: TextStyle(fontSize: 10.sp, fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 16.sp),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: verifyCommand));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.copiedToClipboard), duration: const Duration(seconds: 2)),
                          );
                        },
                        tooltip: loc.copy,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              loc.ramCalculationExplanation,
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.close, style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }
}
