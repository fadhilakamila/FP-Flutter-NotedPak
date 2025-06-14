import 'package:flutter/material.dart';

// Definisi warna primer dari LoginPage untuk konsistensi di seluruh widget
const Color _primaryBlue = Color(0xFF4285F4);
const Color _lightBorderColor = Color(0xFFE9ECEF);

// Fungsi helper untuk mendapatkan warna latar belakang tag DotTag.
// Ini adalah fungsi top-level dan bisa diakses dari file lain yang mengimpor note_tag.dart.
Color getDotTagBackgroundColor(String tag) {
  switch (tag.toLowerCase()) {
    case 'hobby':
      return Colors.purple[700]!;
    case 'daily':
      return Colors.blue[700]!;
    case 'college':
      return Colors.orange[700]!;
    case 'personal routine':
      return Colors.purple[700]!;
    case 'life':
      return Colors.red[700]!;
    case 'work':
      return Colors.green[700]!;
    case 'health':
      return Colors.pink[700]!;
    case 'finance':
      return Colors.teal[700]!;
    case 'travel':
      return Colors.indigo[700]!;
    case 'ideas':
      return Colors.amber[700]!;
    case 'shopping':
      return Colors.cyan[700]!;
    case 'goals':
      return Colors.brown[700]!;
    case 'uncategorized': // Tambahkan kasus untuk tag 'Uncategorized'
      return Colors.grey[500]!; // Warna abu-abu untuk uncategorized
    default:
      return Colors.grey[700]!;
  }
}

/// Widget dasar untuk menampilkan tag catatan.
/// Ini dapat disesuaikan dengan warna latar belakang dan teks yang berbeda.
/// Memiliki opsi untuk menampilkan tombol hapus.
class NoteTag extends StatelessWidget {
  final String tag;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showDeleteButton;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const NoteTag({
    super.key,
    required this.tag,
    this.onDelete,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.showDeleteButton = true,
    this.padding,
    this.fontSize,
  });

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'life':
        return Colors.orange[100]!;
      case 'college':
        return Colors.blue[100]!;
      case 'personal routine':
        return Colors.purple[100]!;
      case 'work':
        return Colors.green[100]!;
      case 'health':
        return Colors.red[100]!;
      case 'finance':
        return Colors.teal[100]!;
      case 'travel':
        return Colors.indigo[100]!;
      case 'ideas':
        return Colors.amber[100]!;
      case 'shopping':
        return Colors.pink[100]!;
      case 'goals':
        return Colors.cyan[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getTextColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'life':
        return Colors.orange[800]!;
      case 'college':
        return Colors.blue[800]!;
      case 'personal routine':
        return Colors.purple[800]!;
      case 'work':
        return Colors.green[800]!;
      case 'health':
        return Colors.red[800]!;
      case 'finance':
        return Colors.teal[800]!;
      case 'travel':
        return Colors.indigo[800]!;
      case 'ideas':
        return Colors.amber[800]!;
      case 'shopping':
        return Colors.pink[800]!;
      case 'goals':
        return Colors.cyan[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getTagColor(tag);
    final txtColor = textColor ?? _getTextColor(tag);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bgColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(
                fontSize: fontSize ?? 14,
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (showDeleteButton && onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: txtColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget tag versi hanya baca (read-only), cocok untuk tampilan filter atau daftar.
/// Memiliki opsi untuk menandai sebagai terpilih.
class ReadOnlyNoteTag extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;

  const ReadOnlyNoteTag({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryBlue : _lightBorderColor,
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Widget tag kustom yang didesain khusus agar sesuai dengan gaya biru
/// yang terlihat di gambar UI "Edit Note" terbaru.
/// Secara default menampilkan tombol hapus.
class BlueNoteTag extends StatelessWidget {
  final String tag;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showDeleteButton;

  const BlueNoteTag({
    super.key,
    required this.tag,
    this.onDelete,
    this.onTap,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _primaryBlue, // Latar belakang selalu biru
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white, // Teks selalu putih
                fontWeight: FontWeight.w500,
              ),
            ),

            if (showDeleteButton && onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan daftar tag, dengan opsi untuk menambahkan tombol "Add tag".
class TagList extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onTagDelete;
  final Function(String)? onTagTap;
  final bool showAddButton;
  final VoidCallback? onAddTag;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const TagList({
    super.key,
    required this.tags,
    this.onTagDelete,
    this.onTagTap,
    this.showAddButton = false,
    this.onAddTag,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        ...tags
            .map(
              (tag) => DotTag(
                tag: tag,
                child: onTagDelete != null
                    ? GestureDetector(
                        onTap: () => onTagDelete!(tag),
                        child: Container(
                          padding: const EdgeInsets.only(left: 6),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            )
            .toList(),

        if (showAddButton && onAddTag != null)
          GestureDetector(
            onTap: onAddTag,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _lightBorderColor,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Add tag',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget tag dengan titik berwarna di depannya, sesuai dengan desain UI di gambar.
/// Digunakan untuk tampilan read-only pada daftar catatan.
class DotTag extends StatelessWidget {
  final String tag;
  final Widget?
  child;

  const DotTag({
    super.key,
    required this.tag,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = getDotTagBackgroundColor(tag);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (child != null)
            child!,
        ],
      ),
    );
  }
}