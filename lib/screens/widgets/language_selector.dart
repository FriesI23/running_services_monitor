import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:running_services_monitor/bloc/language_bloc/language_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: 'Language',
      onSelected: (Locale locale) {
        context.read<LanguageBloc>().add(LanguageEvent.changeLanguage(locale));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(value: const Locale('en'), child: Text('English', style: TextStyle(fontSize: 14.sp))),
        PopupMenuItem<Locale>(value: const Locale('bn'), child: Text('বাংলা', style: TextStyle(fontSize: 14.sp))),
      ],
    );
  }
}
