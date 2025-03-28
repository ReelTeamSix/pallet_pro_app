import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

/// The settings screen.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates a new [SettingsScreen] instance.
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  UserSettings? _cachedSettings;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await ref.read(biometricServiceProvider).isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      // Apply optimistic update for immediate feedback
      _cachedSettings = _cachedSettings?.copyWith(useDarkMode: value);
    });

    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .updateUseDarkMode(value);
    } catch (e) {
      // Revert optimistic update on error
      if (_cachedSettings != null) {
        setState(() {
          _cachedSettings = _cachedSettings!.copyWith(useDarkMode: !value);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to update theme: ${e.toString()}',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      // Apply optimistic update for immediate feedback
      _cachedSettings = _cachedSettings?.copyWith(useBiometricAuth: value);
    });

    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .updateUseBiometricAuth(value);
    } catch (e) {
      // Revert optimistic update on error
      if (_cachedSettings != null) {
        setState(() {
          _cachedSettings = _cachedSettings!.copyWith(useBiometricAuth: !value);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to update biometric auth: ${e.toString()}',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStaleThresholdDays(int days) async {
    if (_isLoading) return;

    // Keep track of the previous value for rollback if needed
    final previousValue = _cachedSettings?.staleThresholdDays;
    if (previousValue == null) return;
    
    // Apply optimistic update
    setState(() {
      _isLoading = true;
      _cachedSettings = _cachedSettings?.copyWith(staleThresholdDays: days);
    });

    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .updateStaleThresholdDays(days);
    } catch (e) {
      // Revert optimistic update on error
      if (_cachedSettings != null && previousValue != null) {
        setState(() {
          _cachedSettings = _cachedSettings!.copyWith(staleThresholdDays: previousValue);
        });
      }
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to update stale threshold: ${e.toString()}',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateShowBreakEvenPrice(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      // Apply optimistic update for immediate feedback
      _cachedSettings = _cachedSettings?.copyWith(showBreakEvenPrice: value);
    });

    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .updateShowBreakEvenPrice(value);
    } catch (e) {
      // Revert optimistic update on error
      if (_cachedSettings != null) {
        setState(() {
          _cachedSettings = _cachedSettings!.copyWith(showBreakEvenPrice: !value);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to update show break-even price: ${e.toString()}',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSettingsAsync = ref.watch(userSettingsControllerProvider);

    // Update cached settings when provider has data
    if (userSettingsAsync.hasValue && userSettingsAsync.value != null) {
      _cachedSettings = userSettingsAsync.value;
    }

    // Use cached settings for UI when available
    final UserSettings? userSettings = _cachedSettings ?? userSettingsAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: userSettingsAsync.when(
        data: (providerSettings) {
          if (userSettings == null) {
            return const Center(
              child: Text('Failed to load settings'),
            );
          }

          return ListView(
            children: [
              // Appearance section
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: userSettings.useDarkMode,
                onChanged: _isLoading ? null : _toggleDarkMode,
              ),
              const Divider(),

              // Security section
              _buildSectionHeader(context, 'Security'),
              if (_isBiometricAvailable)
                SwitchListTile(
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text(
                      'Use fingerprint or face recognition to unlock the app'),
                  value: userSettings.useBiometricAuth,
                  onChanged: _isLoading ? null : _toggleBiometricAuth,
                ),
              if (!_isBiometricAvailable)
                ListTile(
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text(
                      'Biometric authentication is not available on this device'),
                  enabled: false,
                ),
              const Divider(),

              // Inventory settings section
              _buildSectionHeader(context, 'Inventory Settings'),
              ListTile(
                title: const Text('Stale Threshold'),
                subtitle: Text(
                    'Items are considered stale after ${userSettings.staleThresholdDays} days'),
                trailing: DropdownButton<int>(
                  value: userSettings.staleThresholdDays,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            _updateStaleThresholdDays(value);
                          }
                        },
                  items: [7, 14, 30, 60, 90].map((days) {
                    return DropdownMenuItem<int>(
                      value: days,
                      child: Text('$days days'),
                    );
                  }).toList(),
                ),
              ),
              SwitchListTile(
                title: const Text('Show Break-Even Price'),
                subtitle: const Text(
                    'Display break-even price on inventory items'),
                value: userSettings.showBreakEvenPrice,
                onChanged: _isLoading
                    ? null
                    : (value) => _updateShowBreakEvenPrice(value),
              ),
              const Divider(),

              // About section
              _buildSectionHeader(context, 'About'),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('Pallet Pro v3.8.0'),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.all(context.spacingMd),
      child: Text(
        title,
        style: context.titleMedium?.copyWith(
          color: context.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
