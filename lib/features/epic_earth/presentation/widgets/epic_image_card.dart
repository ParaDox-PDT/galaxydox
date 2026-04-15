import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../domain/entities/epic_image.dart';
import '../pages/epic_earth_detail_page.dart';

class EpicImageCard extends StatelessWidget {
  const EpicImageCard({super.key, required this.image});

  final EpicImage image;

  static final DateFormat _dateFormat = DateFormat.yMMMd();
  static final DateFormat _timeFormat = DateFormat.Hms();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'epic-earth-image-${image.identifier}-${image.image}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      EpicEarthDetailPage(image: image, heroTag: heroTag),
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceElevated.withValues(alpha: 0.94),
                    AppColors.surface.withValues(alpha: 0.98),
                  ],
                ),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: PremiumNetworkImage(
                            imageUrl: image.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            image.caption.isEmpty
                                ? 'Earth from DSCOVR'
                                : image.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateFormat.format(image.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _timeFormat.format(image.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              color: AppColors.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
