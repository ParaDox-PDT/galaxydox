import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bookmarks/presentation/bookmark_controller.dart';

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    super.key,
    required this.bookmarkId,
    this.savedLabel = 'Saved',
    this.unsavedLabel = 'Save',
  });

  final String bookmarkId;
  final String savedLabel;
  final String unsavedLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isBookmarkedProvider(bookmarkId));

    return OutlinedButton.icon(
      onPressed: () async {
        HapticFeedback.selectionClick();
        await ref.read(bookmarkControllerProvider.notifier).toggle(bookmarkId);
      },
      icon: Icon(
        isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
      ),
      label: Text(isSaved ? savedLabel : unsavedLabel),
    );
  }
}
