import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class DefaultRoute extends StatelessWidget {
  const DefaultRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ERROR', style: context.bold)),
      body: Center(
        child: Text('WRONG ROUTING DECLARE', style: context.extraBold),
      ),
    );
  }
}
