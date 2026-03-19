import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'calendar_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/file_type_badge.dart';
import '../folders/folder_provider.dart';

enum CalendarMode { notes, documents }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarMode _mode = CalendarMode.notes;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  DateTime get _today => DateTime.now();

  void _previousMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final markedDates = _mode == CalendarMode.notes
        ? ref.watch(
            datesWithNotesProvider(_focusedMonth.year, _focusedMonth.month))
        : ref.watch(datesWithDocumentsProvider(
            _focusedMonth.year, _focusedMonth.month));

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Календарь',
          style: AppTextStyles.appBarTitle.copyWith(color: t.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: t.border),
        ),
      ),
      body: Column(
        children: [
          // Mode toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(kSpaceLG, 14, kSpaceLG, 0),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: t.surfaceVar,
                borderRadius: BorderRadius.circular(kRadiusMD),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'Заметки',
                    selected: _mode == CalendarMode.notes,
                    onTap: () => setState(() {
                      _mode = CalendarMode.notes;
                      _selectedDate = null;
                    }),
                  ),
                  _ModeTab(
                    label: 'Документы',
                    selected: _mode == CalendarMode.documents,
                    onTap: () => setState(() {
                      _mode = CalendarMode.documents;
                      _selectedDate = null;
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: kSpaceMD),

          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
            child: Row(
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                  color: t.inkMuted,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Expanded(
                  child: Text(
                    _monthName(_focusedMonth),
                    style: AppTextStyles.titleMedium.copyWith(color: t.ink),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                  color: t.inkMuted,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),

          const SizedBox(height: kSpaceSM),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
            child: Row(
              children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                  .map((d) => Expanded(
                        child: Text(
                          d,
                          style: AppTextStyles.caption
                              .copyWith(color: t.inkSubtle),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Calendar grid
          markedDates.when(
            loading: () => const SizedBox(height: 240),
            error: (_, _) => const SizedBox(height: 240),
            data: (marked) => _CalendarGrid(
              focusedMonth: _focusedMonth,
              today: _today,
              selectedDate: _selectedDate,
              markedDates: marked,
              onDateTap: (date) => setState(() {
                _selectedDate =
                    _selectedDate?.day == date.day &&
                            _selectedDate?.month == date.month
                        ? null
                        : date;
              }),
            ),
          ),

          Divider(height: 1, color: t.border),

          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(
                kSpaceLG, kSpaceMD, kSpaceLG, kSpaceSM),
            child: Text(
              _mode == CalendarMode.notes
                  ? 'ЗАМЕТКИ — ${_monthNameShort(_focusedMonth)}'
                  : _selectedDate != null
                      ? _dayLabel(_selectedDate!).toUpperCase()
                      : 'ДОКУМЕНТЫ — ${_monthNameShort(_focusedMonth)}',
              style: AppTextStyles.sectionHeader.copyWith(color: t.inkSubtle),
            ),
          ),

          // Content area
          Expanded(
            child: _mode == CalendarMode.notes
                ? _MonthlyNotesList(
                    year: _focusedMonth.year,
                    month: _focusedMonth.month,
                    onEdit: (note) => _showNoteDialog(
                        context,
                        DateTime(note.date.year, note.date.month, note.date.day),
                        note: note),
                    dayLabel: _dayLabel,
                  )
                : _selectedDate == null
                    ? _EmptySelection(mode: _mode)
                    : _DocumentsForDate(date: _selectedDate!),
          ),
        ],
      ),
      floatingActionButton: _mode == CalendarMode.notes
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showNoteDialog(context, _selectedDate ?? _today),
              backgroundColor: t.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day} ${_monthDayShort(_selectedDate!)}'
                    : 'Заметка на сегодня',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Future<void> _showNoteDialog(BuildContext context, DateTime date,
      {Note? note}) async {
    final controller = TextEditingController(text: note?.content ?? '');
    final db = ref.read(appDatabaseProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final t = ArkvioTheme.of(ctx);
        return Container(
          color: t.surface,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                kSpaceLG,
                kSpaceLG,
                kSpaceLG,
                MediaQuery.of(ctx).viewInsets.bottom + kSpaceXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note == null ? 'Новая заметка' : 'Редактировать',
                      style: AppTextStyles.appBarTitle.copyWith(color: t.ink),
                    ),
                    const Spacer(),
                    if (note != null)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: t.danger),
                        onPressed: () async {
                          await db.notesDao.deleteNote(note.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          ref.invalidate(notesForDateProvider);
                          ref.invalidate(datesWithNotesProvider);
                          ref.invalidate(allNotesForMonthProvider);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _dayLabel(date),
                  style: AppTextStyles.caption.copyWith(color: t.inkMuted),
                ),
                const SizedBox(height: kSpaceMD),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 5,
                  minLines: 3,
                  style: AppTextStyles.bodyLarge.copyWith(color: t.ink),
                  decoration: InputDecoration(
                    hintText: 'Напишите заметку...',
                    hintStyle:
                        AppTextStyles.bodyLarge.copyWith(color: t.inkSubtle),
                    filled: true,
                    fillColor: t.surfaceVar,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadiusMD),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadiusMD),
                      borderSide: BorderSide(color: t.accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: kSpaceMD),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      final midnight =
                          DateTime(date.year, date.month, date.day);
                      if (note == null) {
                        await db.notesDao.insertNote(NotesCompanion(
                          content: Value(text),
                          date: Value(midnight),
                        ));
                      } else {
                        await db.notesDao
                            .updateNote(note.copyWith(content: text));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      ref.invalidate(notesForDateProvider);
                      ref.invalidate(datesWithNotesProvider);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: t.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD)),
                    ),
                    child: Text(
                      'Сохранить',
                      style: AppTextStyles.buttonLarge
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(DateTime d) {
    const months = [
      '',
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return '${months[d.month]} ${d.year}';
  }

  String _monthNameShort(DateTime d) {
    const months = [
      '',
      'ЯНВ',
      'ФЕВ',
      'МАР',
      'АПР',
      'МАЙ',
      'ИЮН',
      'ИЮЛ',
      'АВГ',
      'СЕН',
      'ОКТ',
      'НОЯ',
      'ДЕК'
    ];
    return '${months[d.month]} ${d.year}';
  }

  String _dayLabel(DateTime d) {
    const months = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _monthDayShort(DateTime d) {
    const months = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек'
    ];
    return months[d.month];
  }
}

// ─── Mode toggle tab ─────────────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? t.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusSM),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? t.accent : t.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Calendar grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime today;
  final DateTime? selectedDate;
  final Set<DateTime> markedDates;
  final void Function(DateTime) onDateTap;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.today,
    required this.selectedDate,
    required this.markedDates,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        children: List.generate(
          rows,
          (row) => Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final date = DateTime(
                  focusedMonth.year, focusedMonth.month, dayNum);
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final isSelected = selectedDate != null &&
                  date.day == selectedDate!.day &&
                  date.month == selectedDate!.month &&
                  date.year == selectedDate!.year;
              final isMarked = markedDates.contains(
                  DateTime(date.year, date.month, date.day));

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateTap(date),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? t.accent
                          : isToday
                              ? t.accentLight
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(kRadiusSM),
                      border: isToday && !isSelected
                          ? Border.all(color: t.accent, width: 1.5)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: AppTextStyles.tileName.copyWith(
                            fontWeight: isToday || isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? t.accent
                                    : t.ink,
                          ),
                        ),
                        if (isMarked && !isSelected)
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: t.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Empty selection state ────────────────────────────────────────────────────

class _EmptySelection extends StatelessWidget {
  final CalendarMode mode;

  const _EmptySelection({required this.mode});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return LayoutBuilder(
      builder: (_, constraints) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (constraints.maxHeight > 120) ...[
              Icon(
                mode == CalendarMode.notes
                    ? Icons.edit_note_outlined
                    : Icons.folder_open_outlined,
                size: 48,
                color: t.inkSubtle,
              ),
              const SizedBox(height: kSpaceMD),
            ],
            Text(
              mode == CalendarMode.notes
                  ? 'Выберите дату чтобы\nпосмотреть или добавить заметку'
                  : 'Выберите дату чтобы\nпосмотреть документы',
              style: AppTextStyles.bodyMedium.copyWith(
                color: t.inkMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── All notes for month (sorted: today → future → past) ─────────────────────

class _MonthlyNotesList extends ConsumerWidget {
  final int year;
  final int month;
  final void Function(Note) onEdit;
  final String Function(DateTime) dayLabel;

  const _MonthlyNotesList({
    required this.year,
    required this.month,
    required this.onEdit,
    required this.dayLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final notesAsync = ref.watch(allNotesForMonthProvider(year, month));
    return notesAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
      error: (e, _) => Center(
          child: Text('Ошибка: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: t.danger))),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Text(
              'Нет заметок в этом месяце',
              style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted),
            ),
          );
        }

        // Group notes by date
        final today =
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final Map<DateTime, List<Note>> grouped = {};
        for (final n in notes) {
          final d = DateTime(n.date.year, n.date.month, n.date.day);
          grouped.putIfAbsent(d, () => []).add(n);
        }

        // Sort dates: today first, then future ascending, then past descending
        final dates = grouped.keys.toList()
          ..sort((a, b) {
            int priority(DateTime d) {
              if (d == today) return 0;
              if (d.isAfter(today)) return 1;
              return 2;
            }

            final pa = priority(a);
            final pb = priority(b);
            if (pa != pb) return pa.compareTo(pb);
            if (pa == 2) return b.compareTo(a); // past: newest first
            return a.compareTo(b); // today + future: nearest first
          });

        // Flatten into list items: date header + note cards
        final items = <Widget>[];
        for (final date in dates) {
          final isToday = date == today;
          final label = isToday ? 'Сегодня' : dayLabel(date);
          items.add(_DateHeader(label: label, isToday: isToday));
          for (final note in grouped[date]!) {
            items.add(_NoteCard(note: note, onEdit: onEdit));
            items.add(const SizedBox(height: kSpaceSM));
          }
          items.add(const SizedBox(height: kSpaceXS));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
              kSpaceLG, kSpaceXS, kSpaceLG, kSpaceLG),
          children: items,
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  final bool isToday;

  const _DateHeader({required this.label, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: kSpaceSM, bottom: kSpaceXS),
      child: Text(
        label,
        style: AppTextStyles.sectionHeader.copyWith(
          color: isToday ? t.accent : t.inkSubtle,
        ),
      ),
    );
  }
}

// ─── Single note card ─────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final Note note;
  final void Function(Note) onEdit;

  const _NoteCard({required this.note, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return GestureDetector(
      onTap: () => onEdit(note),
      child: Container(
        padding: const EdgeInsets.all(kSpaceMD),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(color: t.border, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: t.ink,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(width: kSpaceSM),
            Icon(Icons.edit_outlined, size: 16, color: t.inkSubtle),
          ],
        ),
      ),
    );
  }
}

// ─── Documents list for a date ────────────────────────────────────────────────

class _DocumentsForDate extends ConsumerWidget {
  final DateTime date;

  const _DocumentsForDate({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ArkvioTheme.of(context);
    final docsAsync = ref.watch(documentsForDateProvider(date));
    return docsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
      error: (e, _) => Center(
          child: Text('Ошибка: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: t.danger))),
      data: (docs) {
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'Нет документов за этот день',
              style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: kSpaceLG, vertical: kSpaceXS),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final doc = docs[i];
            return GestureDetector(
              onTap: () => context.push('/document/${doc.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceMD, vertical: kSpaceSM),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(kRadiusMD),
                  border: Border.all(color: t.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    FileTypeBadge(fileType: doc.fileType),
                    const SizedBox(width: kSpaceSM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title,
                            style: AppTextStyles.tileName
                                .copyWith(color: t.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            doc.fileType.toUpperCase() +
                                (doc.fileSizeKb > 0
                                    ? ' · ${doc.fileSizeKb} КБ'
                                    : ''),
                            style: AppTextStyles.tileSubtitle
                                .copyWith(color: t.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: t.inkSubtle),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
