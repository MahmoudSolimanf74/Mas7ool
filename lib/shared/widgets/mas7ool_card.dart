import 'package:flutter/material.dart';

class Mas7oolCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const Mas7oolCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color ?? const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: border ??
            Border.all(
              color: const Color(0xFF334155).withAlpha(153),
              width: 1,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
