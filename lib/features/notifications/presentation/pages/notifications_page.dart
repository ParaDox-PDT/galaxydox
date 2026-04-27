import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = _notificationsHorizontalPaddingFor(
          constraints.crossAxisExtent,
        );
        final contentWidth = math.max(
          0.0,
          constraints.crossAxisExtent - (horizontalPadding * 2),
        );
        final layout = _notificationsLayoutFor(contentWidth);
        final rowCount = (notifications.length / layout.columns).ceil();

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, rowIndex) {
              final startIndex = rowIndex * layout.columns;

              if (layout.columns == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCard(startIndex),
                );
              }

              final nextIndex = startIndex + 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCard(startIndex)),
                    SizedBox(width: layout.spacing),
                    Expanded(
                      child: nextIndex < notifications.length
                          ? _buildCard(nextIndex)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }, childCount: rowCount),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index) {
    final notification = notifications[index];
    return _NotificationCard(
      key: ValueKey(notification.id),
      notification: notification,
      dateFormat: dateFormat,
      onTap: () => onTap(notification),
    );
  }
}

class _NotificationsLoadingSliver extends StatelessWidget {
  const _NotificationsLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = _notificationsHorizontalPaddingFor(
          constraints.crossAxisExtent,
        );
        final contentWidth = math.max(
          0.0,
          constraints.crossAxisExtent - (horizontalPadding * 2),
        );
        final layout = _notificationsLayoutFor(contentWidth);
        const itemCount = 4;
        final rowCount = (itemCount / layout.columns).ceil();

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, rowIndex) {
              final startIndex = rowIndex * layout.columns;

              if (layout.columns == 1) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: _NotificationLoadingCard(),
                );
              }

              final nextIndex = startIndex + 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _NotificationLoadingCard()),
                    SizedBox(width: layout.spacing),
                    Expanded(
                      child: nextIndex < itemCount
                          ? const _NotificationLoadingCard()
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }, childCount: rowCount),
          ),
        );
      },
    );
  }
}

class _NotificationsLayout {
  const _NotificationsLayout({required this.columns, required this.spacing});

  final int columns;
  final double spacing;
}

double _notificationsHorizontalPaddingFor(double viewportWidth) {
  final centeredGutter = math.max(
    0.0,
    (viewportWidth - AppConstants.contentMaxWidth) / 2,
  );
  return centeredGutter + AppConstants.pagePadding;
}

_NotificationsLayout _notificationsLayoutFor(double width) {
  if (width >= 920) {
    return const _NotificationsLayout(columns: 2, spacing: 18);
  }

  return const _NotificationsLayout(columns: 1, spacing: 12);
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    super.key,
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
  void didUpdateWidget(_NotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notification.imageUrl != widget.notification.imageUrl) {
      _showImage = _isDisplayableImageUrl(widget.notification.imageUrl);
    }
  }

  static final _unreadBorderColor = AppColors.primary.withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notification = widget.notification;
    final createdAt = notification.createdAt == null
        ? null
        : widget.dateFormat.format(notification.createdAt!.toLocal());
    final borderColor =
        notification.isRead ? AppColors.outlineSoft : _unreadBorderColor;

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
            blurSigma: 0,
            borderColor: borderColor,
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
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return const ColoredBox(color: AppColors.surfaceStrong);
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(color: AppColors.surfaceStrong);
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onLoadFailed());
          return const SizedBox.shrink();
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) =>
          const ColoredBox(color: AppColors.surfaceStrong),
      errorWidget: (context, url, error) {
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

  static final _secondaryFill = AppColors.secondary.withValues(alpha: 0.12);
  static final _secondaryBorder = AppColors.secondary.withValues(alpha: 0.24);
  static final _primaryFill = AppColors.primary.withValues(alpha: 0.12);
  static final _primaryBorder = AppColors.primary.withValues(alpha: 0.24);

  @override
  Widget build(BuildContext context) {
    final Color accent;
    final Color fill;
    final Color border;
    switch (type) {
      case AppNotificationType.newWallpaper:
        accent = AppColors.secondary;
        fill = _secondaryFill;
        border = _secondaryBorder;
      case AppNotificationType.unknown:
        accent = AppColors.primary;
        fill = _primaryFill;
        border = _primaryBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
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
