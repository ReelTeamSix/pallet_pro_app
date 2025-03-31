import 'package:flutter/material.dart';

/// Placeholder screen for the main dashboard.
class DashboardScreen extends StatelessWidget {
  /// Creates a new [DashboardScreen] instance.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Dashboard Screen - Content goes here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 