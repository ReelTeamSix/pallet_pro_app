import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dashboard Screen - Content goes here!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNotifier.inventoryList);
              },
              child: const Text('Go to Inventory (Temp)'),
            ),
          ],
        ),
      ),
    );
  }
} 