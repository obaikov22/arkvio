import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'search_provider.dart';
import '../../shared/widgets/document_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final resultsAsync = ref.watch(searchDocumentsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск',
            style: AppTextStyles.appBarTitle.copyWith(color: t.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: t.border),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                kSpaceLG, kSpaceMD, kSpaceLG, kSpaceSM),
            child: SearchBar(
              controller: _controller,
              hintText: 'Поиск по названию, тегам, типу файла...',
              hintStyle: WidgetStatePropertyAll(
                  AppTextStyles.bodyMedium.copyWith(color: t.inkSubtle)),
              textStyle: WidgetStatePropertyAll(
                  AppTextStyles.bodyMedium.copyWith(color: t.ink)),
              leading: Icon(Icons.search, color: t.inkSubtle),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: t.inkMuted),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
            ),
          ),

          if (_query.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kSpaceLG, vertical: kSpaceSM),
              child: Text(
                'Введите минимум 2 символа',
                style: AppTextStyles.caption.copyWith(color: t.inkSubtle),
              ),
            ),

          Expanded(
            child: resultsAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: t.accent)),
              error: (e, _) => Center(
                  child: Text('Ошибка: $e',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: t.danger))),
              data: (docs) {
                if (_query.length < 2) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(kSpaceXXL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_outlined,
                              size: 48, color: t.inkSubtle),
                          const SizedBox(height: kSpaceLG),
                          Text(
                            'Ищите по названию документа,\nтегам или типу файла (PDF, DOCX)',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: t.inkSubtle),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(kSpaceXXL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.find_in_page_outlined,
                              size: 48, color: t.inkSubtle),
                          const SizedBox(height: kSpaceLG),
                          Text(
                            'Ничего не найдено по\n«$_query»',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: t.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kSpaceLG, vertical: kSpaceXS),
                      child: Text(
                        'Найдено: ${docs.length}',
                        style:
                            AppTextStyles.caption.copyWith(color: t.inkMuted),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kSpaceMD),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: kSpaceSM),
                        itemBuilder: (context, i) =>
                            DocumentListTile(document: docs[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
