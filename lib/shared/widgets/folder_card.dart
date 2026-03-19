import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/documents/documents_provider.dart';

class FolderCard extends ConsumerWidget {
  final Folder folder;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const FolderCard({
    super.key,
    required this.folder,
    this.onLongPress,
    this.trailing,
  });

  Color get _folderColor {
    final hex = folder.colorHex.replaceFirst('#', '');
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return kColorAccent;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final countAsync = ref.watch(documentCountInFolderProvider(folder.id));
    final folderColor = _folderColor;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: BorderSide(color: t.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: t.accentLight,
        highlightColor: t.accentLight.withValues(alpha: 0.5),
        onTap: () => context.push('/folder/${folder.id}'),
        onLongPress: onLongPress,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left accent bar — corners clipped by Card
            Container(width: 3, height: 68, color: folderColor),
            const SizedBox(width: kSpaceMD),
            // Folder icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: folderColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(kRadiusSM),
              ),
              child: Icon(Icons.folder_outlined, color: folderColor, size: 20),
            ),
            const SizedBox(width: kSpaceMD),
            // Name + count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.name,
                    style: AppTextStyles.tileName.copyWith(color: t.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  countAsync.when(
                    data: (count) => Text(
                      '$count файл${_plural(count)}',
                      style: AppTextStyles.caption.copyWith(color: t.inkMuted),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Pin indicator
            if (folder.pinned)
              Padding(
                padding: const EdgeInsets.only(right: kSpaceXS),
                child: Icon(Icons.push_pin, size: 14, color: t.accent),
              ),
            // Drag handle (injected from HomeScreen)
            ?trailing,
          ],
        ),
      ),
    );
  }

  String _plural(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'ов';
    switch (count % 10) {
      case 1:
        return '';
      case 2:
      case 3:
      case 4:
        return 'а';
      default:
        return 'ов';
    }
  }
}
