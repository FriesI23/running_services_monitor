import 'package:flutter/material.dart';

class SetupStepItem extends StatelessWidget {
  final String number;
  final String text;

  const SetupStepItem({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(padding: const EdgeInsets.only(top: 2), child: Text(text)),
          ),
        ],
      ),
    );
  }
}
