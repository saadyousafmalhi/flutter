import 'package:flutter/material.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.check_circle,
            color: scheme.onPrimaryContainer,
            size: 36,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Iradon',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
