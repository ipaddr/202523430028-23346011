import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY("user_id") REFERENCES "user"("id"),
  PRIMARY KEY("id" AUTOINCREMENT)
);''';

class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map['id'] as int,
        email = map['email'] as String;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map['id'] as int,
        userId = map['user_id'] as int,
        text = map['text'] as String,
        isSyncedWithCloud = (map['is_synced_with_cloud'] as int) == 1 ? true : false;
}

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];
  
  
  DatabaseUser? _user;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  static final NotesService _shared = NotesService._sharedInstance();
  
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  
  factory NotesService() => _shared;

 
  Stream<List<DatabaseNote>> get allNotes => 
      _notesStreamController.stream.map((notes) {
        final currentUser = _user;
        if (currentUser != null) {
          return notes.where((note) => note.userId == currentUser.id).toList();
        } else {
          return [];
        }
      });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> open() async {
    if (_db != null) return;
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, 'notes.db');
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } catch (e) {
      throw Exception('Tidak bisa membuka database');
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final results = await db.query(
      'user',
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) throw Exception('User tidak ditemukan');
    
    final user = DatabaseUser.fromRow(results.first);
    _user = user;
    return user;
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final results = await db.query('user', limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) throw Exception('User sudah ada');
    final userId = await db.insert('user', {'email': email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      _user = user;
      return user;
    } catch (e) {
      final createdUser = await createUser(email: email);
      _user = createdUser; 
      return createdUser;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    const text = '';
    final noteId = await db.insert('note', {
      'user_id': owner.id,
      'text': text,
      'is_synced_with_cloud': 1,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final deletedCount = await db.delete('note', where: 'id = ?', whereArgs: [id]);
    if (deletedCount == 0) throw Exception('Gagal menghapus note');
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final updatesCount = await db.update(
      'note',
      {'text': text, 'is_synced_with_cloud': 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatesCount == 0) throw Exception('Gagal update note');
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((n) => n.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final notes = await db.query('note', limit: 1, where: 'id = ?', whereArgs: [id]);
    if (notes.isEmpty) throw Exception('Note tidak ditemukan');
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((n) => n.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _db;
    if (db == null) throw Exception('Database belum terbuka');
    final notes = await db.query('note');
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }
}