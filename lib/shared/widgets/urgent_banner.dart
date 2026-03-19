import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class UrgentBanner extends StatelessWidget {
  final List<Document> documents;

  const UrgentBanner({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    final t = ArkvioTheme.of(context);
    final shown = documents.take(3).toList();
    final hasMore = documents.length > 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceLG, kSpaceMD, kSpaceLG, kSpaceSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusLG),
        child: Container(
          color: t.urgentLight,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 4, color: t.urgent),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: t.urgent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: kSpaceSM),
                          Text(
                            'Требуют внимания',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: t.urgent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceSM),
                      ...shown.map(
                        (doc) => GestureDetector(
                          onTap: () => context.push('/document/${doc.id}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Text(
                                  '→ ',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: t.urgent),
                                ),
                                Expanded(
                                  child: Text(
                                    doc.title,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: t.ink),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (hasMore)
                        GestureDetector(
                          onTap: () => context.push('/deadlines'),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Показать все (${documents.length})',
                              style: AppTextStyles.caption.copyWith(
                                color: t.urgent,
                                decoration: TextDecoration.underline,
                                decorationColor: t.urgent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
