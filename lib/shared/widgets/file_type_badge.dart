import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/file_utils.dart';

class FileTypeBadge extends StatelessWidget {
  final String fileType;

  const FileTypeBadge({super.key, required this.fileType});

  ({Color bg, Color text}) get _colors => switch (fileType) {
    'pdf'   => (bg: const Color(0xFFFEE8E8), text: const Color(0xFF9B2335)),
    'docx'  => (bg: const Color(0xFFE8F0FE), text: const Color(0xFF1A5296)),
    'xlsx'  => (bg: const Color(0xFFE8F5E9), text: const Color(0xFF1B5E20)),
    'image'          => (bg: const Color(0xFFFFF3E0), text: const Color(0xFFB85C00)),
    'note' || 'note_list' || 'note_checklist'
                     => (bg: const Color(0xFFEDE7F6), text: const Color(0xFF4527A0)),
    _                => (bg: const Color(0xFFF0EDE6), text: const Color(0xFF6B6860)),
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      width: 36,
      height: 44,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        fileTypeLabel(fileType),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c.text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
