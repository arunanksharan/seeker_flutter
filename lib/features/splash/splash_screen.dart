import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement actual splash logic (check auth, load initial data)
    // For now, just shows a loading indicator
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
