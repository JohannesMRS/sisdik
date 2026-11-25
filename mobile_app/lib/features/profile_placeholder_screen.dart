import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile')), body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('Placeholder profil'),
    const SizedBox(height: 16),
    OutlinedButton(onPressed: () async => context.read<AuthProvider>().logout(), child: const Text('Keluar')),
  ])));
}
