import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_page.dart';

class MarsRoverPage extends StatelessWidget {
  const MarsRoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Mars Rover Gallery',
      description:
          'The rover feature is lined up for filterable galleries, date and sol browsing, and immersive photo details.',
      highlights: [
        'Rover selection',
        'Sol and earth date filters',
        'Photo metadata detail',
      ],
      ctaLabel: 'Back to Home',
    );
  }
}
