import 'package:flutter/material.dart';

/// Rounded panel + “Highlights” heading like the reference screen.
class DashboardHighlightsPanel extends StatelessWidget {
  const DashboardHighlightsPanel({
    super.key,
    required this.child,
    this.title = 'Highlights',
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Single stat tile: large value, label, optional footer caption (no icons).
class DashboardHighlightStatCard extends StatelessWidget {
  const DashboardHighlightStatCard({
    super.key,
    required this.value,
    required this.label,
    this.footer,
    this.footerColor,
    this.minHeight = 132,
  });

  final String value;
  final String label;
  final String? footer;
  final Color? footerColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: tt.headlineMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 34,
                height: 1.05,
                letterSpacing: -1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: tt.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (footer != null && footer!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                footer!,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: footerColor ?? cs.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
