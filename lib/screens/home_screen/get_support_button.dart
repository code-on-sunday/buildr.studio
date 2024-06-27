import 'package:ambilytics/ambilytics.dart';
import 'package:buildr_studio/analytics_events.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GetSupportButton extends StatelessWidget {
  const GetSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadTooltip(
      builder: (_) => const Text('Get support'),
      child: ShadButton.ghost(
        onPressed: () {
          ambilytics?.sendEvent(AnalyticsEvents.joinChatRoomPressed.name, null);
          launchUrlString("https://discord.gg/JVQmxkBqMY");
        },
        size: ShadButtonSize.icon,
        icon: const Icon(Icons.contact_support),
      ),
    );
  }
}
