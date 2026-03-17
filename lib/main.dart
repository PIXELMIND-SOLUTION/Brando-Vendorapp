import 'package:brando_vendor/provider/auth/auth_provider.dart';
import 'package:brando_vendor/provider/auth/profile_provider.dart';
import 'package:brando_vendor/provider/create/create_hostel_provider.dart';
import 'package:brando_vendor/provider/navbar/navbar_provider.dart';
import 'package:brando_vendor/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavbarProvider()),

        ChangeNotifierProvider(create: (_) => VendorProvider()),

        ChangeNotifierProvider(create: (_) => VendorProfileProvider()),

        ChangeNotifierProvider(create: (_) => HostelProvider()),
      ],
      child: MaterialApp(
        title: 'BRANDO VENDOR',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
