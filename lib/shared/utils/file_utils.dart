String formatFileSize(int sizeKb) {
  if (sizeKb < 1024) return '$sizeKb КБ';
  final mb = sizeKb / 1024;
  return '${mb.toStringAsFixed(1)} МБ';
}

String fileTypeLabel(String fileType) {
  switch (fileType) {
    case 'pdf':
      return 'PDF';
    case 'docx':
      return 'DOC';
    case 'xlsx':
      return 'XLS';
    case 'image':
      return 'IMG';
    case 'note':
      return 'ТЕКСТ';
    case 'note_list':
      return 'СПИСОК';
    case 'note_checklist':
      return 'ЧЕК';
    default:
      return 'FILE';
  }
}
