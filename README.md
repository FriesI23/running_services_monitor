# Running Services Monitor

A Flutter Android app that displays all running apps and services on your device, including system apps. This app uses **Shizuku** to access system information without requiring root access.

## Features

✨ **View Running Services**: See all active services on your device
📱 **System & User Apps**: Separate views for system and user applications  
🔍 **Detailed Information**: View package names, PIDs, process names, and service classes
🎨 **Material Design 3**: Modern UI with dark mode support
🔄 **Real-time Refresh**: Update the service list anytime
🚫 **No Root Required**: Uses Shizuku for elevated permissions via ADB

## Screenshots

The app displays running services similar to the Android Developer Options "Running Services" screen that was available in older Android versions.

## Requirements

### Essential
- **Android 7.0 (API 24) or higher**
- **Shizuku app** installed and running
- For Android 11+: Wireless Debugging enabled
- For Android 10 and below: ADB connection to PC

### Permissions
- `QUERY_ALL_PACKAGES` - To list all installed apps
- Shizuku permission - Granted through Shizuku app

## Installation

### 1. Install Shizuku

Download and install Shizuku from:
- [Google Play Store](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api)
- [GitHub Releases](https://github.com/RikkaApps/Shizuku/releases)

### 2. Start Shizuku Service

#### For Android 11 and above (Wireless Debugging):
1. Enable **Developer Options** on your device
2. Enable **Wireless Debugging** in Developer Options
3. Open Shizuku app
4. Tap **"Pair"** or **"Start"**
5. Follow the on-screen pairing instructions

#### For Android 10 and below (ADB via PC):
1. Enable **Developer Options** and **USB Debugging**
2. Connect your device to a PC via USB
3. Run this ADB command on your PC:
   ```bash
   adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
   ```
4. Shizuku should now be running

### 3. Install This App

Build and install the APK:
```bash
flutter build apk --release
flutter install
```

Or run in debug mode:
```bash
flutter run
```

### 4. Grant Shizuku Permission

When you first open the app, it will request Shizuku permission. Tap **"Allow"** when prompted.

## How It Works

This app uses Shizuku to execute privileged ADB commands without root access:

1. **Shizuku Integration**: The app connects to the Shizuku service running on your device
2. **Dumpsys Commands**: Executes `dumpsys activity services` to get running service information
3. **Parsing**: Parses the dumpsys output to extract service details (package name, PID, process name, etc.)
4. **App Metadata**: Uses `device_apps` package to fetch app names and icons
5. **Categorization**: Separates services into System and User categories

## Technical Details

### Dependencies
- `shizuku_api: ^1.2.2` - Shizuku API integration
- `device_apps: ^2.2.0` - App information and icons
- `flutter_svg: ^2.0.10+1` - SVG support

### Architecture
```
lib/
├── models/
│   └── service_info.dart          # Data models for services and processes
├── services/
│   ├── shizuku_service.dart       # Shizuku wrapper and command execution
│   └── process_service.dart       # Service fetching and parsing logic
├── screens/
│   └── home_screen.dart           # Main screen with tabs
├── widgets/
│   ├── service_list_item.dart     # Service display widget
│   └── shizuku_setup_dialog.dart  # Setup instructions dialog
└── main.dart                      # App entry point
```

### Key Components

**ShizukuService**: Manages Shizuku initialization, permission requests, and command execution

**ProcessService**: Fetches running services using `dumpsys` and parses the output

**HomeScreen**: Main UI with three tabs (All, User, System) and refresh functionality

## Limitations

- **Android Restrictions**: Due to Android security policies, some service information may be limited
- **Shizuku Dependency**: Requires Shizuku to be running; service stops when device reboots
- **Parsing Accuracy**: Dumpsys output format may vary across Android versions
- **No Service Control**: This app only displays services; it cannot start/stop them

## Why Shizuku?

Starting from Android 8.0 (API 26), the `ActivityManager.getRunningServices()` API was deprecated and restricted. Third-party apps can no longer query all running services on the device for privacy and security reasons.

Shizuku provides a solution by:
- Running a privileged service that can access system APIs
- Allowing apps to execute ADB commands without root
- Working on non-rooted devices via Wireless Debugging (Android 11+) or USB ADB

## Troubleshooting

### "Shizuku is not running"
- Open the Shizuku app and start the service
- For Android 11+: Enable Wireless Debugging
- For Android 10-: Connect to PC and run the ADB command

### "Permission denied"
- Grant Shizuku permission when prompted
- Check that Shizuku service is running properly

### "No services found"
- Tap the refresh button
- Ensure Shizuku has proper permissions
- Check that dumpsys commands work in Shizuku app

### App crashes on startup
- Ensure minSdk is 24 or higher
- Verify all dependencies are installed: `flutter pub get`
- Check Android manifest configuration

## Building from Source

```bash
# Clone the repository
git clone <repository-url>
cd running_services_monitor

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

## License

This project is open source. Feel free to use and modify as needed.

## Credits

- **Shizuku** by RikkaApps - https://github.com/RikkaApps/Shizuku
- **Flutter** - https://flutter.dev
- **device_apps** package - https://pub.dev/packages/device_apps

## Disclaimer

This app is for informational purposes only. It displays running services but does not modify system behavior. Use responsibly and respect user privacy.

---

**Note**: This app is designed for users who want to monitor running services on their device, similar to the "Running Services" feature that was available in Android Developer Options in older Android versions (before it was hidden in newer versions like HyperOS).
