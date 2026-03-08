import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile tile
          profileAsync.when(
            loading: () => const ListTile(title: Text('Loading profile...')),
            error: (_, _) =>
                const ListTile(title: Text('Could not load profile')),
            data: (profile) => ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Text(
                  (profile?.displayName.isNotEmpty == true
                          ? profile!.displayName[0]
                          : user?.email?[0] ?? '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(profile?.displayName ?? 'No name'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          const Divider(),

          // Notifications toggle
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (profile) => SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              value: profile?.notificationsEnabled ?? true,
              onChanged: (v) async {
                try {
                  await ref.read(firestoreServiceProvider).updateUserProfile(
                    user!.uid,
                    {FirestoreFields.notificationsEnabled: v},
                  );
                  ref.invalidate(userProfileProvider);
                } catch (e) {
                  if (context.mounted) {
                    SnackbarHelper.showError(context, e.toString());
                  }
                }
              },
            ),
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Kigali City App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Kigali City App',
            ),
          ),
          const Divider(),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
