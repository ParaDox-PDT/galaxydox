import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/frosted_panel.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/premium_refresh_indicator.dart';
import '../../../../shared/widgets/premium_scrollbar.dart';
import '../../../../shared/widgets/space_scaffold.dart';
import '../../../../shared/widgets/state_panel.dart';
import '../../domain/app_notification_entity.dart';
import '../providers/notification_navigation_service.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollController = ScrollController();
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationsProvider.notifier).syncSilently();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateFormat = DateFormat('dd MMM yyyy - HH:mm');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return SpaceScaffold(
      body: PremiumScrollbar(
        controller: _scrollController,
        child: PremiumRefreshIndicator(
          onRefresh: () =>
              ref.read(notificationsProvider.notifier).forceRefresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.contentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.pagePadding,
                        12,
                        AppConstants.pagePadding,
                        16,
                      ),
                      child: PageHeader(
                        title: 'Notifications',
                        subtitle:
                            'Stay up to date with the latest wallpapers, announcements, and app updates - all in one place.',
                        actions: [
                          if (unreadCount > 0)
                            OutlinedButton.icon(
                              onPressed: () => ref
                                  .read(notificationsProvider.notifier)
                                  .markAllAsRead(),
                              icon: const Icon(Icons.done_all_rounded),
                              label: const Text('Mark all read'),
                            ),
                          FilledButton.icon(
                            onPressed: () => ref
                                .read(notificationsProvider.notifier)
                                .forceRefresh(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    ),
                  ),
                ),
              ),
              notificationsAsync.when(
                loading: () => const _NotificationsLoadingSliver(),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.contentMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.pagePadding,
                        ),
                        child: StatePanel(
                          title: 'Unable to load notifications',
                          message: _resolveErrorMessage(error),
                          icon: Icons.notifications_off_rounded,
                          accent: AppColors.warning,
                          actions: [
                            StatePanelAction(
                              label: 'Try again',
                              icon: Icons.refresh_rounded,
                              onPressed: () => ref
                                  .read(notificationsProvider.notifier)
                                  .forceRefresh(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppConstants.contentMaxWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.pagePadding,
                            ),
                            child: StatePanel(
                              title: 'No notifications yet',
                              message:
                                  'No new notifications right now. Check back later - updates about new wallpapers and features will appear here.',
                              icon: Icons.notifications_none_rounded,
                              accent: AppColors.secondary,
                              actions: [
                                StatePanelAction(
                                  label: 'Refresh',
                                  icon: Icons.refresh_rounded,
                                  onPressed: () => ref
                                      .read(notificationsProvider.notifier)
                                      .forceRefresh(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return _NotificationsListSliver(
                    notifications: notifications,
                    dateFormat: _dateFormat,
                    onTap: _openNotification,
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNotification(AppNotificationEntity notification) async {
    await ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    if (!mounted || !notification.isActionable) return;

    final router = ref.read(notificationNavigationServiceProvider);
    router.pushFromEntity(GoRouter.of(context), notification);
  }

  String _resolveErrorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}

class _NotificationsListSliver extends StatelessWidget {
  const _NotificationsListSliver({
    required this.notifications,
    required this.dateFormat,
    required this.onTap,
  });

  final List<AppNotificationEntity> notifications;
  final DateFormat dateFormat;
  final ValueChanged<AppNotificationEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePadding,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _notificationsLayoutFor(constraints.maxWidth);
                final itemWidth = layout.itemWidthFor(constraints.maxWidth);

                return Wrap(
                  spacing: layout.spacing,
                  runSpacing: 14,
                  children: [
                    for (var index = 0; index < notifications.length; index++)
                      SizedBox(
                        width: itemWidth,
                        child:
                            _NotificationCard(
                                  notification: notifications[index],
                                  dateFormat: dateFormat,
                                  onTap: () => onTap(notifications[index]),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: 60 * index),
                                  duration: AppConstants.motionMedium,
                                )
                                .slideY(begin: 0.06, end: 0),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsLoadingSliver extends StatelessWidget {
  const _NotificationsLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePadding,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _notificationsLayoutFor(constraints.maxWidth);
                final itemWidth = layout.itemWidthFor(constraints.maxWidth);

                return Wrap(
                  spacing: layout.spacing,
                  runSpacing: 14,
                  children: List.generate(
                    4,
                    (_) => SizedBox(
                      width: itemWidth,
                      child: const _NotificationLoadingCard(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsLayout {
  const _NotificationsLayout({required this.columns, required this.spacing});

  final int columns;
  final double spacing;

  double itemWidthFor(double width) {
    return math.max(0, (width - (spacing * (columns - 1))) / columns);
  }
}

_NotificationsLayout _notificationsLayoutFor(double width) {
  if (width >= 920) {
    return const _NotificationsLayout(columns: 2, spacing: 18);
  }

  return const _NotificationsLayout(columns: 1, spacing: 12);
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.notification,
    required this.dateFormat,
    required this.onTap,
  });

  final AppNotificationEntity notification;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  late bool _showImage;

  @override
  void initState() {
    super.initState();
    _showImage = _isDisplayableImageUrl(widget.notification.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notification = widget.notification;
    final createdAt = notification.createdAt == null
        ? null
        : widget.dateFormat.format(notification.createdAt!.toLocal());

    return Semantics(
      button: true,
      label: notification.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: FrostedPanel(
            padding: EdgeInsets.zero,
            borderColor: notification.isRead
                ? AppColors.outlineSoft
                : AppColors.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusMedium - 2),
                      ),
                      child: AspectRatio(
                        aspectRatio: 2.1,
                        child: _NotificationImage(
                          imageUrl: notification.imageUrl!,
                          onLoadFailed: _hideImage,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _NotificationTypeChip(type: notification.type),
                                if (createdAt != null)
                                  Text(
                                    createdAt,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        notification.title.trim().isEmpty
                            ? 'Untitled notification'
                            : notification.title,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (notification.body.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          notification.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.isActionable
                                  ? 'Open related content'
                                  : 'View in notifications inbox',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: notification.isActionable
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.textSecondary,
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
    );
  }

  void _hideImage() {
    if (!mounted || !_showImage) return;
    setState(() => _showImage = false);
  }
}

class _NotificationImage extends StatelessWidget {
  const _NotificationImage({
    required this.imageUrl,
    required this.onLoadFailed,
  });

  final String imageUrl;
  final VoidCallback onLoadFailed;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return const ColoredBox(color: AppColors.surfaceStrong);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return const ColoredBox(color: AppColors.surfaceStrong);
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onLoadFailed());
        return const SizedBox.shrink();
      },
    );
  }
}

bool _isDisplayableImageUrl(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return false;
  }

  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return false;
  }

  return uri.scheme == 'http' || uri.scheme == 'https';
}

class _NotificationTypeChip extends StatelessWidget {
  const _NotificationTypeChip({required this.type});

  final AppNotificationType type;

  @override
  Widget build(BuildContext context) {
    final Color accent;
    switch (type) {
      case AppNotificationType.newWallpaper:
        accent = AppColors.secondary;
      case AppNotificationType.unknown:
        accent = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Text(
        type.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotificationLoadingCard extends StatelessWidget {
  const _NotificationLoadingCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: const ColoredBox(
            color: AppColors.surfaceElevated,
            child: SizedBox(height: 180, width: double.infinity),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: AppColors.surfaceStrong,
        );
  }
}
