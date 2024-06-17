import 'package:buildr_studio/env/env.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onClose;
  final Widget child;

  const Sidebar({
    super.key,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        borderRadius: ShadTheme.of(context).radius,
        border: Border.all(
          width: 1,
          color: ShadTheme.of(context).colorScheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'buildr.studio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (Env.wireDashProjectId != null && Env.wireDashSecret != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('(v${GetIt.I<PackageInfo>().version})',
                        style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
