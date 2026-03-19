import 'package:flutter/material.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String _statusText = '';
  bool _hasError = false;

  Future<void> _startUpdate() async {
    setState(() {
      _downloading = true;
      _hasError = false;
      _statusText = 'Скачивание...';
    });

    try {
      final filePath = await UpdateService.downloadApk(
        widget.updateInfo.downloadUrl,
        (received, total) {
          if (total > 0) {
            setState(() {
              _progress = received / total;
              final mb = (received / 1024 / 1024).toStringAsFixed(1);
              final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
              _statusText = '$mb / $totalMb МБ';
            });
          }
        },
      );

      setState(() => _statusText = 'Установка...');
      await UpdateService.installApk(filePath);

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _downloading = false;
        _hasError = true;
        _statusText = 'Ошибка загрузки. Попробуйте позже.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ArkvioTheme.of(context);
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusLG)),
      title: Text(
        'Доступно обновление',
        style: AppTextStyles.appBarTitle.copyWith(color: t.ink),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Версия ${widget.updateInfo.version}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: t.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.updateInfo.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: kSpaceSM),
            Text(
              widget.updateInfo.releaseNotes,
              style: AppTextStyles.bodyMedium.copyWith(color: t.inkMuted, height: 1.5),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_downloading || _hasError) ...[
            const SizedBox(height: kSpaceMD),
            if (_downloading)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: t.surfaceVar,
                  color: t.accent,
                  minHeight: 6,
                ),
              ),
            const SizedBox(height: kSpaceXS),
            Text(
              _statusText,
              style: AppTextStyles.caption.copyWith(
                color: _hasError ? t.danger : t.inkMuted,
              ),
            ),
          ],
        ],
      ),
      actions: _downloading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Позже',
                    style: AppTextStyles.button.copyWith(color: t.inkMuted)),
              ),
              FilledButton(
                onPressed: _startUpdate,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusMD)),
                ),
                child: Text('Обновить',
                    style: AppTextStyles.button.copyWith(color: Colors.white)),
              ),
            ],
    );
  }
}
