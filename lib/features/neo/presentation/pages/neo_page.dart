import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_page.dart';

class NeoPage extends StatelessWidget {
  const NeoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Near-Earth Object Watch',
      description:
          'Asteroid intelligence lands next with readable telemetry cards, hazard indicators, and timeline-driven feeds.',
      highlights: [
        'Hazard status',
        'Velocity and miss distance',
        'Elegant data density',
      ],
      ctaLabel: 'Back to Home',
    );
  }
}
