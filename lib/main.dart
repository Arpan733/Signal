import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal/providers/live_location_provider.dart';
import 'package:signal/providers/signal_algo_provider.dart';
import 'package:signal/screens/splash_screen.dart';

import 'providers/name_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LiveLocationProvider()),
        ChangeNotifierProvider(create: (context) => SignalAlgoProvider()),
        ChangeNotifierProvider(create: (context) => NameProvider()),
      ],
      child: const MaterialApp(
        title: 'Flutter Demo',
        home: SplashScreen(),
      ),
    );
  }
}
