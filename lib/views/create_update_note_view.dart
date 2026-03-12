import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynoteku/services/auth/note_services.dart'; // Path sudah disesuaikan

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNote> createOrGetExistingNote() async {
    // Mengambil email dari user yang sedang login di Firebase
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      throw Exception('Email tidak ditemukan. Pastikan user sudah login.');
    }
    
    final owner = await _notesService.getUser(email: currentUserEmail);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _textController.dispose();
    super.dispose();
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: createOrGetExistingNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Start typing your note...'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}