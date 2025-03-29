import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';

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

    // --- Check for PIN setup BEFORE enabling biometrics ---
    if (value == true) { // Only check when enabling
      // Read latest state directly from the provider for the check
      final currentSettings = ref.read(userSettingsControllerProvider).valueOrNull;
      final pinAuthEnabled = currentSettings?.usePinAuth ?? false;
      final pinHashSet = currentSettings?.pinHash != null && currentSettings!.pinHash!.isNotEmpty;

      if (!pinAuthEnabled || !pinHashSet) {
        // Show message and navigate to PIN setup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please set up and enable PIN authentication first as a fallback.'),
              duration: Duration(seconds: 4),
            ),
          );
          // Navigate to PIN setup
          final currentLocation = GoRouterState.of(context).matchedLocation;
          if (currentLocation != '/pin-setup') {
             context.push('/pin-setup'); 
          }
        }
        // IMPORTANT: Return here to prevent the switch from toggling on
        // and prevent the actual controller update.
        return; 
      }
    }
    // --- End PIN check ---

    // Continue with optimistic update and controller call only if check passes or disabling
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

  /// Updates whether to use PIN authentication.
  Future<void> _togglePinAuth(bool value) async {
    if (_isLoading) return;

    // --- NEW CHECK: Prevent disabling PIN if Biometrics is enabled ---
    if (value == false) { // Only check when attempting to disable
      // Read latest state directly from the provider for the check
      final currentSettings = ref.read(userSettingsControllerProvider).valueOrNull;
      final biometricAuthEnabled = currentSettings?.useBiometricAuth ?? false;

      if (biometricAuthEnabled) {
        // Show message and prevent disabling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot disable PIN while Biometric Authentication is enabled. Disable biometrics first.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        // IMPORTANT: Return here to prevent the switch from toggling off
        // and prevent the actual controller update.
        return;
      }
    }
    // --- End Biometric check ---

    // If enabling PIN but no PIN is set, navigate to setup first
    if (value && (_cachedSettings?.pinHash == null || _cachedSettings!.pinHash!.isEmpty)) {
      // Add a check to prevent navigation if already on PinSetupScreen
      final currentLocation = GoRouterState.of(context).matchedLocation;
      if (currentLocation != '/pin-setup') {
         context.push('/pin-setup').then((_) {
             // After returning from setup, refresh state if needed
             // The controller should update the state automatically
         });
      }
      return; // Don't toggle the switch directly yet
    }

    // If disabling PIN, clear the hash (this only happens if biometric check above passes)
    String? pinHashToSet = _cachedSettings?.pinHash;
    if (!value) {
        pinHashToSet = null; // Clear hash when disabling
    }

    setState(() {
      _isLoading = true;
      // Optimistic update
      _cachedSettings = _cachedSettings?.copyWith(usePinAuth: value, pinHash: pinHashToSet);
    });

    try {
      // Update via controller
      await ref.read(userSettingsControllerProvider.notifier).updatePinSettings(
            usePinAuth: value,
            pinHash: pinHashToSet,
          );
    } catch (e) {
      // Revert optimistic update on error
       if (_cachedSettings != null) {
         setState(() {
           _cachedSettings = _cachedSettings!.copyWith(usePinAuth: !value, pinHash: _cachedSettings?.pinHash); // Revert to original values
         });
       }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to update PIN auth: ${e.toString()}',
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

  /// Handles the sign-out process.
  Future<void> _signOut() async {
    if (_isLoading) return; // Prevent multiple taps

    // Optional: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sign Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return; // User cancelled
    }

    setState(() {
      _isLoading = true;
    });

    // Show signing out SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing out...'),
          duration: Duration(seconds: 2), // Short duration
        ),
      );
      // Attempt to hide quickly if sign-out is fast
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
    }

    try {
      // Use ref.read for one-off actions like sign out
      await ref.read(authControllerProvider.notifier).signOut();
      // Navigation is handled by the router listening to auth state changes
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException
                  ? e.message
                  : 'Failed to sign out: ${e.toString()}'
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Only update state if the widget is still mounted
      // If sign-out was successful, the widget might unmount before this runs
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
              // PIN Authentication Toggle
              SwitchListTile(
                title: const Text('PIN Authentication'),
                subtitle: const Text('Use a 4-digit PIN to unlock the app'),
                value: userSettings.usePinAuth,
                onChanged: _isLoading ? null : _togglePinAuth,
              ),
              // Change PIN Tile (only enabled if PIN Auth is enabled)
              ListTile(
                title: const Text('Change PIN'),
                subtitle: const Text('Set or update your 4-digit PIN'),
                leading: const Icon(Icons.pin),
                enabled: userSettings.usePinAuth && !_isLoading,
                onTap: userSettings.usePinAuth && !_isLoading 
                    ? () {
                        // Add a check to prevent navigation if already on PinSetupScreen
                        final currentLocation = GoRouterState.of(context).matchedLocation;
                        if (currentLocation != '/pin-setup') {
                           context.push('/pin-setup'); 
                        }
                       } 
                    : null,
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

              // Add Sign Out Button Here
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: context.errorColor),
                title: Text('Sign Out', style: TextStyle(color: context.errorColor)),
                // Disable button while loading
                onTap: _isLoading ? null : _signOut,
              ),
              const SizedBox(height: 20), // Add some padding at the bottom
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
