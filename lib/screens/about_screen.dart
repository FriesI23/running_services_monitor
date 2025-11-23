import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'widgets/about_info_tile.dart';
import 'widgets/about_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // static const String appName = 'Running Services Monitor';
  String version = '';
  static const String email = 'biplobsd11@gmail.com';
  static const String sourceCodeUrl = 'https://github.com/biplobsd/running_services_monitor';
  static const String blogsUrl = 'https://biplobsd.github.io';
  static const String buyMeCoffeeUrl = 'https://buymeacoffee.com/biplobsd';
  static const String developerName = 'Biplob Kumar Sutradhar';

  @override
  void initState() {
    super.initState();
    // version = AppLocalizations.of(context)!.loading; // Context not available in initState for localization usually, but we can init with empty or loading
    _loadPackageInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (version.isEmpty) {
      version = AppLocalizations.of(context)!.loading;
    }
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = 'v${packageInfo.version}';
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.about)),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AboutHeader(version: version),
                  const SizedBox(height: 32),
                  AboutInfoTile(
                    icon: Icons.person,
                    title: AppLocalizations.of(context)!.developer,
                    subtitle: developerName,
                  ),
                  AboutInfoTile(
                    icon: Icons.email,
                    title: AppLocalizations.of(context)!.email,
                    subtitle: email,
                    onTap: () => _launchUrl('mailto:$email'),
                  ),
                  AboutInfoTile(
                    icon: Icons.code,
                    title: AppLocalizations.of(context)!.sourceCode,
                    subtitle: 'github.com/biplobsd/running_services_monitor',
                    onTap: () => _launchUrl(sourceCodeUrl),
                  ),
                  AboutInfoTile(
                    icon: Icons.web,
                    title: AppLocalizations.of(context)!.blogs,
                    subtitle: 'biplobsd.github.io',
                    onTap: () => _launchUrl(blogsUrl),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () => _launchUrl(buyMeCoffeeUrl),
                      icon: const Icon(Icons.coffee),
                      label: Text(AppLocalizations.of(context)!.buyMeCoffee),
                      style: FilledButton.styleFrom(backgroundColor: Colors.amber[800], foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.madeInBangladesh,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
