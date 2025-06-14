import 'package:flutter/material.dart';
import 'package:noted_pak/widgets/note_tag.dart'; // Ini mengimpor getDotTagBackgroundColor

// Definisi warna primer dari LoginPage
const Color _primaryBlue = Color(0xFF4285F4);
const Color _lightBorderColor = Color(0xFFE9ECEF);
const Color _darkTextColor = Colors.black87;

class NewTagDialog extends StatefulWidget {
  final List<String> existingTags;
  final List<String> currentNoteTags;

  const NewTagDialog({
    super.key,
    required this.existingTags,
    required this.currentNoteTags,
  });

  @override
  State<NewTagDialog> createState() => _NewTagDialogState();
}

class _NewTagDialogState extends State<NewTagDialog> {
  late TextEditingController _tagController;
  List<String> _filteredSuggestedTags = [];

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _filterSuggestedTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _filterSuggestedTags() {
    final query = _tagController.text.toLowerCase();
    _filteredSuggestedTags = widget.existingTags
        .where(
          (tag) =>
              tag.toLowerCase().contains(query) &&
              !widget.currentNoteTags.contains(tag),
        )
        .toSet()
        .toList();
    _filteredSuggestedTags.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isNotEmpty) {
      if (!widget.currentNoteTags.contains(tagText)) {
        Navigator.of(context).pop(tagText);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$tagText" already exists in this note!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectSuggestedTag(String tag) {
    setState(() {
      _tagController.text = tag;
      _filterSuggestedTags(); // Perbarui daftar saran berdasarkan input field yang baru
      if (widget.currentNoteTags.contains(tag)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$tag" already exists in this note!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showSuggestedTagsSection = _filteredSuggestedTags.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: showSuggestedTagsSection ? 400 : 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add tag',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _darkTextColor,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _tagController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter tag name',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _lightBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filterSuggestedTags(); // Perbarui saran saat mengetik
                });
              },
              onSubmitted: (value) {
                _addTag();
              },
            ),

            if (showSuggestedTagsSection) ...[
              const SizedBox(height: 16),
              Text(
                'Suggested tags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filteredSuggestedTags.map((tag) {
                      return GestureDetector(
                        onTap: () => _selectSuggestedTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: getDotTagBackgroundColor(
                              tag,
                            ), // Warna sesuai DotTag
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: _tagController.text.trim().isEmpty
                      ? null
                      : _addTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue, // Warna biru saat aktif
                    disabledBackgroundColor: _primaryBlue.withAlpha(
                      (0.5 * 255).round(),
                    ),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withAlpha(
                      (0.7 * 255).round(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
