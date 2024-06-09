import 'package:buildr_studio/env/env.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    return SizedBox(
      width: 400,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
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
                      if (Env.wireDashProjectId != null &&
                          Env.wireDashSecret != null)
                        Text('(v${GetIt.I<PackageInfo>().version})',
                            style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
