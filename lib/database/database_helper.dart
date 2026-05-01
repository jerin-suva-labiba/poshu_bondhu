import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet_model.dart';
import '../models/weight_model.dart';
import '../models/note_model.dart';
import '../models/vaccine_model.dart';
import '../models/deworming_model.dart';
import '../models/document_model.dart';
import '../models/memory_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posha_bondhu.db');
    return _database!;
  }

   Future<Database> _initDB(String filePath) async {
     final dbPath = await getDatabasesPath();
     final path = join(dbPath, filePath);
     return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
   }

   Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       await db.execute('ALTER TABLE pets ADD COLUMN petType TEXT DEFAULT "Dog"');
     }
     if (oldVersion < 3) {
       await db.execute('''CREATE TABLE memories (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         petId INTEGER NOT NULL, imagePath TEXT NOT NULL, timestamp TEXT NOT NULL)''');
     }
   }

    Future _createDB(Database db, int version) async {
      await db.execute('''CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, petType TEXT NOT NULL, birthday TEXT NOT NULL,
        imagePath TEXT, breed TEXT, gender TEXT)''');

     await db.execute('''CREATE TABLE weights (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, weight REAL NOT NULL, date TEXT NOT NULL)''');

     await db.execute('''CREATE TABLE notes (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, title TEXT NOT NULL,
       content TEXT NOT NULL, date TEXT NOT NULL)''');

     await db.execute('''CREATE TABLE vaccines (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, vaccineName TEXT NOT NULL,
       lastDate TEXT NOT NULL, nextDate TEXT NOT NULL, notes TEXT)''');

     await db.execute('''CREATE TABLE deworming (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, medicineName TEXT NOT NULL,
       lastDate TEXT NOT NULL, nextDate TEXT NOT NULL, notes TEXT)''');

     await db.execute('''CREATE TABLE documents (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, fileName TEXT NOT NULL,
       filePath TEXT NOT NULL, notes TEXT, date TEXT NOT NULL)''');

     await db.execute('''CREATE TABLE memories (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       petId INTEGER NOT NULL, imagePath TEXT NOT NULL, timestamp TEXT NOT NULL)''');
   }

  // PETS
  Future<int> insertPet(Pet pet) async => (await database).insert('pets', pet.toMap());
  Future<List<Pet>> getAllPets() async {
    final maps = await (await database).query('pets');
    return maps.map((m) => Pet.fromMap(m)).toList();
  }
  Future<int> updatePet(Pet pet) async =>
      (await database).update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  Future<int> deletePet(int id) async =>
      (await database).delete('pets', where: 'id = ?', whereArgs: [id]);

  // WEIGHTS
  Future<int> insertWeight(WeightEntry w) async => (await database).insert('weights', w.toMap());
  Future<List<WeightEntry>> getWeights(int petId) async {
    final maps = await (await database).query('weights', where: 'petId = ?', whereArgs: [petId], orderBy: 'date ASC');
    return maps.map((m) => WeightEntry.fromMap(m)).toList();
  }
  Future<int> deleteWeight(int id) async =>
      (await database).delete('weights', where: 'id = ?', whereArgs: [id]);

  // NOTES
  Future<int> insertNote(Note note) async => (await database).insert('notes', note.toMap());
  Future<List<Note>> getNotes(int petId) async {
    final maps = await (await database).query('notes', where: 'petId = ?', whereArgs: [petId], orderBy: 'date DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }
  Future<int> deleteNote(int id) async =>
      (await database).delete('notes', where: 'id = ?', whereArgs: [id]);

  // VACCINES
  Future<int> insertVaccine(VaccineEntry v) async => (await database).insert('vaccines', v.toMap());
  Future<List<VaccineEntry>> getVaccines(int petId) async {
    final maps = await (await database).query('vaccines', where: 'petId = ?', whereArgs: [petId], orderBy: 'lastDate DESC');
    return maps.map((m) => VaccineEntry.fromMap(m)).toList();
  }
  Future<int> deleteVaccine(int id) async =>
      (await database).delete('vaccines', where: 'id = ?', whereArgs: [id]);

  // DEWORMING
  Future<int> insertDeworming(DewormingEntry d) async => (await database).insert('deworming', d.toMap());
  Future<List<DewormingEntry>> getDeworming(int petId) async {
    final maps = await (await database).query('deworming', where: 'petId = ?', whereArgs: [petId], orderBy: 'lastDate DESC');
    return maps.map((m) => DewormingEntry.fromMap(m)).toList();
  }
  Future<int> deleteDeworming(int id) async =>
      (await database).delete('deworming', where: 'id = ?', whereArgs: [id]);

  // DOCUMENTS
  Future<int> insertDocument(DocumentEntry d) async => (await database).insert('documents', d.toMap());
  Future<List<DocumentEntry>> getDocuments(int petId) async {
    final maps = await (await database).query('documents', where: 'petId = ?', whereArgs: [petId], orderBy: 'date DESC');
    return maps.map((m) => DocumentEntry.fromMap(m)).toList();
  }
   Future<int> deleteDocument(int id) async =>
       (await database).delete('documents', where: 'id = ?', whereArgs: [id]);

   // MEMORIES
   Future<int> insertMemory(Memory memory) async => (await database).insert('memories', memory.toMap());
   Future<List<Memory>> getMemories(int petId) async {
     final maps = await (await database).query('memories', where: 'petId = ?', whereArgs: [petId], orderBy: 'timestamp DESC');
     return maps.map((m) => Memory.fromMap(m)).toList();
   }
   Future<int> deleteMemory(int id) async =>
       (await database).delete('memories', where: 'id = ?', whereArgs: [id]);

  // ALL REMINDERS (for calendar)
  Future<Map<String, List<Map<String, String>>>> getAllReminders() async {
    final pets = await getAllPets();
    final db = await database;
    Map<String, List<Map<String, String>>> reminders = {};
    for (var pet in pets) {
      final vaccines = await db.query('vaccines', where: 'petId = ?', whereArgs: [pet.id]);
      final deworm = await db.query('deworming', where: 'petId = ?', whereArgs: [pet.id]);
      for (var v in vaccines) {
        final date = v['nextDate'] as String;
        reminders[date] = reminders[date] ?? [];
        reminders[date]!.add({'type': '💉 Vaccine', 'pet': pet.name, 'detail': v['vaccineName'] as String});
      }
      for (var d in deworm) {
        final date = d['nextDate'] as String;
        reminders[date] = reminders[date] ?? [];
        reminders[date]!.add({'type': '🐛 Deworming', 'pet': pet.name, 'detail': d['medicineName'] as String});
      }
    }
    return reminders;
  }
}