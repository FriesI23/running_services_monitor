import 'package:flutter/material.dart';

class AboutInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const AboutInfoTile({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.open_in_new, size: 16) : null,
    );
  }
}
