import 'package:flutter/material.dart';
import 'package:noted_pak/widgets/new_tag_dialog.dart';
import 'package:noted_pak/widgets/note_tag.dart';
import 'package:noted_pak/widgets/delete_note_alert.dart';

// Definisi warna primer dan lainnya yang konsisten dengan LoginPage
const Color _primaryBlue = Color(0xFF4285F4);
const Color _lightGreyBackground = Color(0xFFF8F9FA);
const Color _lightBorderColor = Color(0xFFE9ECEF);

class NewOrEditNotePage extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  final bool isReadOnly; // Ini adalah override keras untuk mode read-only

  const NewOrEditNotePage({
    Key? key,
    this.existingNote,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _tags = [];
  DateTime? _createdDate;
  DateTime? _lastModifiedDate;

  // State untuk mengontrol mode edit/view
  late bool _isEditingMode;

  // Variabel untuk gaya teks Rich Text Editor
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;

  List<String> _allExistingUserTags = [
    'Personal Routine', 'Life', 'College', 'Work', 'Health',
    'Finance', 'Travel', 'Ideas', 'Shopping', 'Goals',
    'Hobby', 'Daily'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingNote();

    // Inisialisasi _isEditingMode:
    // Jika ini catatan baru, langsung masuk mode edit.
    // Jika catatan yang sudah ada, mulai dalam mode view, kecuali jika isReadOnly widget adalah false.
    _isEditingMode = widget.existingNote == null && !widget.isReadOnly;
    // Jika widget.isReadOnly adalah true, maka selalu dalam mode view (tidak bisa diedit)
    if (widget.isReadOnly) {
      _isEditingMode = false;
    } else if (widget.existingNote != null && widget.existingNote!.isEmpty) {
      // Handle case where existingNote is provided but empty, treat as new note
      _isEditingMode = true;
    } else if (widget.existingNote != null) {
      // For existing notes, start in view mode (unless explicitly forced to edit from external route/param)
      _isEditingMode = false;
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  void _loadExistingNote() {
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'] ?? '';
      _contentController.text = widget.existingNote!['content'] ?? '';
      _tags = List<String>.from(widget.existingNote!['tags'] ?? []);
      _createdDate = _parseDate(widget.existingNote!['createdDate']);
      _lastModifiedDate = _parseDate(widget.existingNote!['lastModifiedDate']);
    } else {
      _createdDate = DateTime.now();
      _lastModifiedDate = DateTime.now();
    }
  }

  DateTime? _parseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _addTag() async {
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) => NewTagDialog(
        existingTags: _allExistingUserTags,
        currentNoteTags: _tags,
      ),
    );
    
    if (newTag != null && newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _lastModifiedDate = DateTime.now();
        if (!_allExistingUserTags.contains(newTag)) {
          _allExistingUserTags.add(newTag);
        }
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _lastModifiedDate = DateTime.now();
    });
  }

  void _saveNote() {
    final noteData = {
      'title': _titleController.text.isEmpty ? 'Title here..' : _titleController.text,
      'content': _contentController.text,
      'tags': _tags,
      'createdDate': _createdDate?.toIso8601String(),
      'lastModifiedDate': DateTime.now().toIso8601String(),
    };
    
    Navigator.pop(context, noteData);
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeleteNoteAlert(); // Pastikan ini const jika tidak ada perubahan state internal
      },
    ).then((result) {
      if (result == true) {
        print("Note deleted!");
        Navigator.pop(context); // Kembali dari NewOrEditNotePage setelah menghapus
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah catatan ini adalah catatan baru (belum pernah disimpan)
    final isNewNote = widget.existingNote == null;
    // Tentukan apakah input field harus read-only (berdasarkan mode atau override isReadOnly)
    final bool _isInputReadOnly = !_isEditingMode || widget.isReadOnly;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isNewNote
              ? 'New Note'
              : (_isEditingMode ? 'Edit Note' : 'View Note'),
          style: const TextStyle(
            color: _primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!isNewNote && !_isEditingMode && !widget.isReadOnly) // Hanya tampilkan Edit jika bukan catatan baru, dalam mode view, dan tidak read-only keras
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingMode = true; // Beralih ke mode edit
                  _lastModifiedDate = DateTime.now(); // Update last modified saat mulai edit
                });
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          if (_isEditingMode && !widget.isReadOnly) // Tampilkan Done dan Delete jika dalam mode edit dan tidak read-only keras
            TextButton(
              onPressed: _saveNote,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          if (!isNewNote && _isEditingMode && !widget.isReadOnly) // Tampilkan menu titik tiga untuk delete hanya jika editing catatan lama dan tidak read-only keras
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Note', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: _primaryBlue),
            ),
        ],
      ),
      body: Column(
        children: [
          // Title Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  readOnly: _isInputReadOnly, // readOnly berdasarkan _isInputReadOnly
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title here..',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (_isEditingMode) { // Hanya update jika dalam mode edit
                      setState(() {
                        _lastModifiedDate = DateTime.now();
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Info Created & Last Modified hanya tampil jika ini catatan yang sudah ada
                if (!isNewNote) ...[
                  Row(
                    children: [
                      Text(
                        'Created',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_createdDate!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Last modified',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_lastModifiedDate!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Tags Section
                Row(
                  children: [
                    Text(
                      'Tags',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isEditingMode && !widget.isReadOnly) // Tombol Add Tag hanya di mode edit
                      ElevatedButton(
                        onPressed: _addTag,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    const Spacer(),
                    if (_tags.isEmpty && _isInputReadOnly) // "No tags added" hanya di view mode
                      Text(
                        'No tags added',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Tags Display
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => DotTag(
                      tag: tag,
                      child: (_isEditingMode && !widget.isReadOnly) // Tombol silang hanya di mode edit
                          ? GestureDetector(
                              onTap: () => _removeTag(tag),
                              child: Container(
                                padding: const EdgeInsets.only(left: 6),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null, // Tidak ada tombol silang di mode view
                    )).toList(),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content Editor
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _contentController,
                        readOnly: _isInputReadOnly, // readOnly berdasarkan _isInputReadOnly
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                          decoration: TextDecoration.combine([
                            if (_isUnderline) TextDecoration.underline,
                            if (_isStrikethrough) TextDecoration.lineThrough,
                          ]),
                        ),
                        decoration: InputDecoration(
                          hintText: 'The..',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (_isEditingMode) { // Hanya update jika dalam mode edit
                            setState(() {
                              _lastModifiedDate = DateTime.now();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Rich Text Toolbar hanya tampil di mode edit
                  if (_isEditingMode && !widget.isReadOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: _lightBorderColor),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.undo),
                            color: Colors.grey[600],
                            onPressed: () { /* Implement undo functionality */ },
                          ),
                          IconButton(
                            icon: const Icon(Icons.redo),
                            color: Colors.grey[600],
                            onPressed: () { /* Implement redo functionality */ },
                          ),
                          
                          const SizedBox(width: 8),
                          
                          IconButton(
                            icon: const Icon(Icons.format_bold),
                            color: _isBold ? _primaryBlue : Colors.grey[600],
                            onPressed: () {
                              setState(() {
                                _isBold = !_isBold;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic),
                            color: _isItalic ? _primaryBlue : Colors.grey[600],
                            onPressed: () {
                              setState(() {
                                _isItalic = !_isItalic;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_underlined),
                            color: _isUnderline ? _primaryBlue : Colors.grey[600],
                            onPressed: () {
                              setState(() {
                                _isUnderline = !_isUnderline;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_strikethrough),
                            color: _isStrikethrough ? _primaryBlue : Colors.grey[600],
                            onPressed: () {
                              setState(() {
                                _isStrikethrough = !_isStrikethrough;
                              });
                            },
                          ),
                          
                          const Spacer(),
                          
                          IconButton(
                            icon: const Icon(Icons.format_list_bulleted),
                            color: Colors.grey[600],
                            onPressed: () { /* Implement bullet list functionality */ },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}