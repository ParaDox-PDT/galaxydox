import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../bookmarks/data/models/bookmark_item.dart';
import '../bookmarks/presentation/providers/bookmark_controller.dart';

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    super.key,
    required this.bookmark,
    this.savedLabel = 'Saved',
    this.unsavedLabel = 'Save',
    this.variant = BookmarkButtonVariant.outlined,
    this.showFeedback = true,
  });

  final BookmarkItem bookmark;
  final String savedLabel;
  final String unsavedLabel;
  final BookmarkButtonVariant variant;
  final bool showFeedback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isBookmarkedProvider(bookmark.id));

    Future<void> onPressed() async {
      HapticFeedback.selectionClick();
      final result = await ref
          .read(bookmarkControllerProvider.notifier)
          .toggle(bookmark);

      if (!context.mounted || !showFeedback) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }

    return switch (variant) {
      BookmarkButtonVariant.outlined => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
        ),
        label: Text(isSaved ? savedLabel : unsavedLabel),
      ),
      BookmarkButtonVariant.icon => Material(
        color: Colors.transparent,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated.withValues(alpha: 0.78),
            border: Border.all(
              color: isSaved
                  ? AppColors.primary.withValues(alpha: 0.36)
                  : AppColors.outlineSoft,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.textPrimary,
            ),
            tooltip: isSaved ? savedLabel : unsavedLabel,
          ),
        ),
      ),
    };
  }
}

enum BookmarkButtonVariant { outlined, icon }
