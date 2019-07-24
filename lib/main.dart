import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gofast/apptheme.dart';
import 'package:gofast/onboarding/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Go Fast',
      theme: AppTheme.appTheme,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('fr', 'FR'),
        const Locale('es', 'ES'),
      ],
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
