import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Single settings icon on the app bar; actions live in the popup menu.
class AppBarSettingsMenu extends StatelessWidget {
  const AppBarSettingsMenu({
    super.key,
    required this.onSelected,
    required this.itemBuilder,
  });

  final void Function(String value) onSelected;
  final PopupMenuItemBuilder<String> itemBuilder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Settings',
      icon: Icon(Icons.settings_outlined, color: scheme.onSurface),
      onSelected: onSelected,
      itemBuilder: itemBuilder,
    );
  }
}

Future<void> showSignOutConfirmDialog(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sign out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Sign out', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
        ),
      ],
    ),
  );
  if (go == true && context.mounted) {
    context.read<AuthCubit>().logout();
  }
}
