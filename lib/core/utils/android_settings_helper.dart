import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AndroidSettingsHelper {
  static Future<void> tryOpenSystemRunningServices() async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.android.settings',
        componentName: 'com.android.settings.SubSettings',
        arguments: <String, dynamic>{':settings:show_fragment': 'com.android.settings.applications.RunningServices'},
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      if (await intent.canResolveActivity() ?? false) {
        await intent.launch();
      } else {
        Fluttertoast.showToast(
          msg: 'Running Services settings not available on this device',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      print("Error: $errorMsg");
      final message = errorMsg.contains('permission')
          ? 'You need root permission to open Running Services settings Or try with Shizuku'
          : 'Error opening Running Services: ${e.toString()}';
      
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
