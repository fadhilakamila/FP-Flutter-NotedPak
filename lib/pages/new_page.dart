// lib/pages/edit_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noted_pak/pages/camera_screen.dart';

import 'package:noted_pak/widgets/new_tag_dialog.dart';
import 'package:noted_pak/widgets/note_tag.dart';
import 'package:noted_pak/widgets/confirmation_dialog.dart';
import 'package:noted_pak/models/note.dart';
import 'package:noted_pak/change_notifiers/notes_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _primaryBlue = Color(0xFF4285F4);
const Color _lightBorderColor = Color(0xFFE9ECEF);

class NewOrEditNotePage extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  final bool isReadOnly;
  final String? initialContent;

  const NewOrEditNotePage({
    super.key,
    this.existingNote,
    this.isReadOnly = false,
    this.initialContent,
  });

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _tags = [];
  DateTime? _dateCreated;
  DateTime? _dateModified;

  late bool _isEditingMode;
  bool _isOcrProcessing = false;

  // Variabel untuk melacak gaya teks yang SEDANG AKTIF PADA SELURUH TEXTFIELD
  bool _isBold = false; // Dikembalikan ke gaya untuk seluruh TextField
  bool _isItalic = false; // Dikembalikan ke gaya untuk seluruh TextField
  bool _isUnderline = false; // Dikembalikan ke gaya untuk seluruh TextField
  bool _isStrikethrough = false; // Dikembalikan ke gaya untuk seluruh TextField

  final List<String> _allExistingUserTags = [
    'Personal Routine',
    'Life',
    'College',
    'Work',
    'Health',
    'Finance',
    'Travel',
    'Ideas',
    'Shopping',
    'Goals',
    'Hobby',
    'Daily',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingNote();
    _setInitialContent();

    if (widget.isReadOnly) {
      _isEditingMode = false;
    } else if (widget.existingNote == null) {
      _isEditingMode = true;
    } else {
      _isEditingMode = false;
    }

    // Hapus listener ini karena tidak lagi digunakan dengan rich text ad-hoc
    // _contentController.addListener(_updateToolbarState);
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

      _dateCreated = _parseDate(widget.existingNote!['dateCreated']);
      _dateModified = _parseDate(widget.existingNote!['dateModified']);

      for (var tag in _tags) {
        if (!_allExistingUserTags.contains(tag)) {
          _allExistingUserTags.add(tag);
        }
      }
    } else {
      _dateCreated = DateTime.now();
      _dateModified = DateTime.now();
    }
  }

  void _setInitialContent() {
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      _contentController.text = widget.initialContent!;
    }
  }

  DateTime? _parseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is Timestamp) {
      return date.toDate();
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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
        _dateModified = DateTime.now();
        if (!_allExistingUserTags.contains(newTag)) {
          _allExistingUserTags.add(newTag);
        }
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _dateModified = DateTime.now();
    });
  }

  void _saveNote() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Confirm Changes',
          content: 'Are you sure you want to save these changes?',
          // ...
        );
      },
    );

    if (confirmed != null && confirmed) {
      if (!mounted) return;

      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save notes.')),
        );
        return;
      }

      Note newOrUpdatedNote = Note(
        id: widget.existingNote != null ? widget.existingNote!['id'] as String? : null,
        title: _titleController.text.isEmpty ? 'Untitled Note' : _titleController.text,
        content: _contentController.text,
        tags: _tags,
        dateCreated: _dateCreated ?? DateTime.now(),
        dateModified: DateTime.now(),
        userId: currentUser.uid, 
      );

      if (newOrUpdatedNote.id == null) {
        await notesProvider.addNote(newOrUpdatedNote);
        print("Note added to Firebase!");
      } else {
        await notesProvider.updateNote(newOrUpdatedNote);
        print("Note updated in Firebase!");
      }

      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Delete Note',
          content: 'Are you sure you want to delete this note?',
          confirmButtonText: 'Delete',
          confirmButtonColor: Colors.red,
          cancelButtonText: 'Cancel',
        );
      },
    ).then((confirmed) async {
      if (confirmed != null && confirmed) {
        if (!mounted) return;

        if (widget.existingNote != null && widget.existingNote!['id'] != null) {
          final notesProvider = Provider.of<NotesProvider>(
            context,
            listen: false,
          );
          String noteIdToDelete = widget.existingNote!['id'];

          await notesProvider.deleteNote(noteIdToDelete);
          print("Note deleted from Firebase!");

          Navigator.of(context).pop();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else {
          print("Cannot delete: Note has no ID.");
        }
      }
    });
  }

  void _showOcrOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scan using Camera'),
                onTap: () async {
                  Navigator.pop(bc);
                  await _scanUsingCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(bc);
                  await _pickFromGalleryAndRecognizeText();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanUsingCamera() async {
    if (_isOcrProcessing) return;

    setState(() {
      _isOcrProcessing = true;
    });

    var status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied.')),
        );
      }
      setState(() {
        _isOcrProcessing = false;
      });
      return;
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera permission permanently denied. Please enable from app settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      setState(() {
        _isOcrProcessing = false;
      });
      return;
    }

    try {
      final String? extractedText = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );

      if (!mounted) return;

      if (extractedText != null && extractedText.isNotEmpty) {
        // --- Penting: Sisipkan teks ke TextField di posisi kursor ---
        _insertTextAtSelection(_contentController, extractedText);
        // ---

        setState(() {
          _dateModified = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text extracted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text extracted or scan cancelled.')),
        );
      }
    } catch (e) {
      print('Error during camera scan OCR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan from camera: $e')),
        );
      }
    } finally {
      setState(() {
        _isOcrProcessing = false;
      });
    }
  }

  Future<void> _pickFromGalleryAndRecognizeText() async {
    print('DEBUG OCR: _pickFromGalleryAndRecognizeText called.');
    if (_isOcrProcessing) {
      print('DEBUG OCR: Already processing. Exiting.');
      return;
    }

    setState(() {
      _isOcrProcessing = true;
    });

    PermissionStatus status;
    print('DEBUG OCR: Requesting Permission.photos...');
    status = await Permission.photos.request();
    print('DEBUG OCR: Permission.photos status: $status');

    if (status.isGranted) {
      print('DEBUG OCR: Permission GRANTED.');
      final ImagePicker picker = ImagePicker();
      XFile? image;
      try {
        print('DEBUG OCR: Calling picker.pickImage from gallery...');
        image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          print('DEBUG OCR: Image selected: ${image.path}');
        } else {
          print('DEBUG OCR: Image selection cancelled by user.');
        }
      } catch (e) {
        print('DEBUG OCR: Error picking image: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
        }
        setState(() {
          _isOcrProcessing = false;
        });
        return;
      }

      if (image != null) {
        BuildContext? loadingDialogContext;

        try {
          print('DEBUG OCR: Initializing TextRecognizer...');
          final TextRecognizer textRecognizer = TextRecognizer();
          print('DEBUG OCR: Creating InputImage from file...');
          final InputImage inputImage = InputImage.fromFilePath(image.path);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) {
              loadingDialogContext = ctx;
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Processing image..."),
                  ],
                ),
              );
            },
          );

          print('DEBUG OCR: Calling textRecognizer.processImage...');
          final RecognizedText recognizedText = await textRecognizer
              .processImage(inputImage);
          print('DEBUG OCR: Text recognition completed.');

          if (loadingDialogContext != null &&
              loadingDialogContext!.mounted &&
              Navigator.of(loadingDialogContext!).canPop()) {
            Navigator.of(loadingDialogContext!).pop();
          }
          textRecognizer.close();

          if (recognizedText.text.isNotEmpty) {
            print(
              'DEBUG OCR: Text extracted. Length: ${recognizedText.text.length}',
            );
            if (mounted) {
              _insertTextAtSelection(_contentController, recognizedText.text);

              setState(() {
                _dateModified = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Text extracted successfully!')),
              );
            }
          } else {
            print('DEBUG OCR: No text found in the selected image.');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No text found in the selected image.'),
                ),
              );
            }
          }
        } catch (e) {
          print('DEBUG OCR: Error during ML Kit processing: $e');
          if (mounted) {
            if (loadingDialogContext != null &&
                loadingDialogContext!.mounted &&
                Navigator.of(loadingDialogContext!).canPop()) {
              Navigator.of(loadingDialogContext!).pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to process image for text: $e')),
            );
          }
        } finally {
          setState(() {
            _isOcrProcessing = false;
          });
        }
      } else {
        print('DEBUG OCR: No image selected by user.');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected.')));
        }
        setState(() {
          _isOcrProcessing = false;
        });
      }
    } else if (status.isDenied) {
      print('DEBUG OCR: Permission DENIED by user. Showing SnackBar.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage/Photos permission denied.')),
        );
      }
      setState(() {
        _isOcrProcessing = false;
      });
    } else if (status.isPermanentlyDenied) {
      print(
        'DEBUG OCR: Permission PERMANENTLY DENIED by user. Prompting settings.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Storage/Photos permission permanently denied. Please enable from app settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      setState(() {
        _isOcrProcessing = false;
      });
    } else {
      print('DEBUG OCR: Unknown permission status: $status');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown permission status: $status')),
        );
      }
      setState(() {
        _isOcrProcessing = false;
      });
    }
  }

  // ========================================================================
  // BAGIAN YANG DIKEMBALIKAN/DIUBAH UNTUK TEXT FORMATTING
  // ========================================================================

  // Fungsi ini dikembalikan untuk mendapatkan TextStyle yang diterapkan ke SELURUH TextField
  TextStyle _getCurrentTextStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.combine([
        if (_isUnderline) TextDecoration.underline,
        if (_isStrikethrough) TextDecoration.lineThrough,
      ]),
    );
  }

  // Fungsi _updateToolbarState tidak lagi diperlukan untuk fungsionalitas ini, bisa dihapus atau dikosongkan.
  // Untuk rich text sejati, fungsi ini akan membaca gaya di posisi kursor.
  void _updateToolbarState() {
    // Fungsi ini tidak melakukan apa-apa yang fungsional untuk styling seluruh TextField.
    // Dulu mencoba mencerminkan gaya seleksi, tapi itu tidak didukung oleh TextField standar.
    // Jika tidak digunakan, bisa dihapus atau biarkan kosong.
  }

  // Fungsi untuk menerapkan gaya ke SELURUH TEXTFIELD
  void _applyStyle(
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  ) {
    setState(() {
      if (fontWeight != null) _isBold = !_isBold;
      if (fontStyle != null) _isItalic = !_isItalic;
      if (decoration == TextDecoration.underline) _isUnderline = !_isUnderline;
      if (decoration == TextDecoration.lineThrough)
        _isStrikethrough = !_isStrikethrough;
      _dateModified =
          DateTime.now(); // Update tanggal modifikasi saat gaya diubah
    });
    // Tidak perlu memanipulasi _contentController secara manual di sini
    // karena TextField akan di-rebuild dengan gaya baru secara otomatis.
  }

  // Fungsi helper untuk menyisipkan teks
  void _insertTextAtSelection(
    TextEditingController controller,
    String textToInsert,
  ) {
    final text = controller.text;
    final selection = controller.selection;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      textToInsert,
    );

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + textToInsert.length,
      ),
    );
  }

  // ========================================================================
  // AKHIR BAGIAN YANG DIKEMBALIKAN/DIUBAH
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final isNewNote = widget.existingNote == null;
    final bool isInputReadOnly = !_isEditingMode || widget.isReadOnly;

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
          isNewNote ? 'New Note' : (_isEditingMode ? 'Edit Note' : 'View Note'),
          style: const TextStyle(
            color: _primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Tombol OCR Scanner
          if (_isEditingMode && !widget.isReadOnly)
            _isOcrProcessing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.document_scanner,
                      color: _primaryBlue,
                    ),
                    onPressed: _showOcrOptions,
                  ),

          // Tombol Done/Edit
          if (!isNewNote && !_isEditingMode && !widget.isReadOnly)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingMode = true;
                  _dateModified = DateTime.now();
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

          if (_isEditingMode && !widget.isReadOnly)
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

          // Tombol More (dengan Delete Note)
          if (!isNewNote && _isEditingMode && !widget.isReadOnly)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                }
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Note',
                            style: TextStyle(color: Colors.red),
                          ),
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
                  readOnly: isInputReadOnly,
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
                    if (_isEditingMode) {
                      setState(() {
                        _dateModified = DateTime.now();
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                if (!isNewNote) ...[
                  Row(
                    children: [
                      Text(
                        'Created',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_dateCreated ?? DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Last modified',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_dateModified ?? DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    if (_isEditingMode && !widget.isReadOnly)
                      ElevatedButton(
                        onPressed: _addTag,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    const Spacer(),
                    if (_tags.isEmpty && isInputReadOnly)
                      Text(
                        'No tags added',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map(
                          (tag) => DotTag(
                            tag: tag,
                            child: (_isEditingMode && !widget.isReadOnly)
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
                                : null,
                          ),
                        )
                        .toList(),
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
                        readOnly: isInputReadOnly,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        // UBAH KEMBALI STYLE KE SINI
                        style:
                            _getCurrentTextStyle(), // Menggunakan gaya untuk seluruh TextField
                        decoration: InputDecoration(
                          hintText: 'The..',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        // HAPUS PROPERTI buildCounter INI
                        // buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        //   return Text.rich(
                        //     TextSpan(
                        //       children: [
                        //         TextSpan(
                        //           text: _contentController.text,
                        //           style: _getCurrentTextStyle(),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // },
                        onChanged: (value) {
                          if (_isEditingMode) {
                            setState(() {
                              _dateModified = DateTime.now();
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Rich Text Toolbar
                  if (_isEditingMode && !widget.isReadOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: _lightBorderColor),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold),
                            color: _isBold
                                ? _primaryBlue
                                : Colors
                                      .grey[600], // Menggunakan _isBold global
                            onPressed: () {
                              _applyStyle(FontWeight.bold, null, null);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic),
                            color: _isItalic
                                ? _primaryBlue
                                : Colors
                                      .grey[600], // Menggunakan _isItalic global
                            onPressed: () {
                              _applyStyle(null, FontStyle.italic, null);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_underlined),
                            color: _isUnderline
                                ? _primaryBlue
                                : Colors
                                      .grey[600], // Menggunakan _isUnderline global
                            onPressed: () {
                              _applyStyle(null, null, TextDecoration.underline);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_strikethrough),
                            color: _isStrikethrough
                                ? _primaryBlue
                                : Colors
                                      .grey[600], // Menggunakan _isStrikethrough global
                            onPressed: () {
                              _applyStyle(
                                null,
                                null,
                                TextDecoration.lineThrough,
                              );
                            },
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