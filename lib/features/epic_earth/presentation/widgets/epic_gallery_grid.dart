import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_heading.dart';
import '../../domain/entities/epic_image.dart';
import 'epic_image_card.dart';

class EpicGalleryGrid extends StatelessWidget {
  const EpicGalleryGrid({super.key, required this.images});

  final List<EpicImage> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          eyebrow: 'Gallery',
          title: 'Natural color Earth frames',
          subtitle:
              'DSCOVR images from the Earth Polychromatic Imaging Camera archive.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 1080
                ? 4
                : constraints.maxWidth >= 760
                ? 3
                : constraints.maxWidth >= 520
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: crossAxisCount == 1 ? 0.92 : 0.78,
              ),
              itemBuilder: (context, index) {
                return EpicImageCard(image: images[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
