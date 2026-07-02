import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/weather_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent, light-icon status bar so the animated backdrop shows
  // through behind it — part of the immersive "spatial" look.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App error:\n${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(const WeatherApp());
    },
    (error, stack) {
      // ignore: avoid_print
      print('Uncaught error: $error');
      print(stack);
    },
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: appTheme,
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
