import 'package:flutter/material.dart';

class ServiceDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const ServiceDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
