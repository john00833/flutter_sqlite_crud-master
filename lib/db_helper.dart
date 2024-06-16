import 'package:flutter_sqlite_crud/student_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'student.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE student (id INTEGER PRIMARY KEY, name TEXT)');
  }

  Future<Student> add(Student student) async {
    var dbClient = await db;
    student.id = await dbClient.insert('student', student.toMap());
    return student;
  }

  Future<List<Student>> getStudents() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query('student', columns: ['id', 'name']);
    List<Student> students = [];
    if (maps.isNotEmpty) {
      for (var map in maps) {
        students.add(Student.fromMap(map));
      }
    }
    return students;
  }

  Future<int> delete(int? id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'student',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Student student) async {
    var dbClient = await db;
    return await dbClient.update(
      'student',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> close() async {
    var dbClient = await db;
    await dbClient.close();
  }
}
