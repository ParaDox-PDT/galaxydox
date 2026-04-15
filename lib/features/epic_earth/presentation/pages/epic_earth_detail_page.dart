import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/metadata_row.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/epic_image.dart';

class EpicEarthDetailPage extends StatelessWidget {
  const EpicEarthDetailPage({
    super.key,
    required this.image,
    required this.heroTag,
  });

  final EpicImage image;
  final String heroTag;

  static final DateFormat _dateTimeFormat = DateFormat.yMMMMd().add_Hms();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: heroTag,
                child: PremiumNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: _TopButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.18,
            maxChildSize: 0.72,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                child: FrostedPanel(
                  padding: EdgeInsets.zero,
                  radius: AppConstants.radiusLarge,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        image.caption.isEmpty
                            ? 'Earth from DSCOVR'
                            : image.caption,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _dateTimeFormat.format(image.date),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (image.hasMetadata) ...[
                        const SizedBox(height: 22),
                        Text(
                          'Metadata',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        ..._metadataRows(image),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static List<Widget> _metadataRows(EpicImage image) {
    final rows = <Widget>[];

    void addRow(String label, String value) {
      rows
        ..add(MetadataRow(label: label, value: value))
        ..add(const SizedBox(height: 12));
    }

    final centroid = image.centroidCoordinates;
    if (centroid != null) {
      addRow(
        'Centroid',
        '${centroid.latitude.toStringAsFixed(4)}, ${centroid.longitude.toStringAsFixed(4)}',
      );
    }

    final dscovr = image.dscovrJ2000Position;
    if (dscovr != null) {
      addRow('DSCOVR J2000', _formatPosition(dscovr));
    }

    final lunar = image.lunarJ2000Position;
    if (lunar != null) {
      addRow('Lunar J2000', _formatPosition(lunar));
    }

    final sun = image.sunJ2000Position;
    if (sun != null) {
      addRow('Sun J2000', _formatPosition(sun));
    }

    final attitude = image.attitudeQuaternions;
    if (attitude != null) {
      addRow(
        'Attitude',
        [
          attitude.q0,
          attitude.q1,
          attitude.q2,
          attitude.q3,
        ].map((value) => value.toStringAsFixed(6)).join(', '),
      );
    }

    if (rows.isNotEmpty) {
      rows.removeLast();
    }

    return rows;
  }

  static String _formatPosition(EpicJ2000Position position) {
    return [
      position.x,
      position.y,
      position.z,
    ].map((value) => value.toStringAsFixed(2)).join(', ');
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}
