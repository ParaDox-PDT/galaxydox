import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_page.dart';

class NasaSearchPage extends StatelessWidget {
  const NasaSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'NASA Media Search',
      description:
          'The search workspace is next in line with debounced queries, grid and list modes, and rich media details.',
      highlights: [
        'Debounced search',
        'Grid and list toggle',
        'Gallery-first discovery',
      ],
      ctaLabel: 'Back to Home',
    );
  }
}
