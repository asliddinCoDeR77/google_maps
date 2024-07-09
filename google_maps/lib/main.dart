import 'package:flutter/material.dart';
import 'package:google_maps/services/location_services.dart';
import 'package:google_maps/splashscreen/splash_screeen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
