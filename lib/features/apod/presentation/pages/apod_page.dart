import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_page.dart';

class ApodPage extends StatelessWidget {
  const ApodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Astronomy Picture of the Day',
      description:
          'The APOD experience is scaffolded next with HD imagery, video handling, metadata, and a cinematic detail view.',
      highlights: [
        'Image and video support',
        'HD preview flow',
        'Rich editorial explanation',
      ],
      ctaLabel: 'Back to Home',
    );
  }
}
