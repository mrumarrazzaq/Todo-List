import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

const String tableName = 'TodoList';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        taskTitle TEXT,
        taskDescription TEXT,
        taskStatus STRING,
        taskDate STRING,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'TaskCollection.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item
  static Future<int> createTask(
      {required String title,
      String? description,
      required String taskDate,
      required String taskStatus}) async {
    final db = await SQLHelper.db();

    final data = {
      'taskTitle': title,
      'taskDescription': description,
      'taskStatus': taskStatus,
      'taskDate': taskDate,
    };
    final id = await db.insert(tableName, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all Task
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await SQLHelper.db();
    return db.query(tableName, orderBy: "id");
  }

  // Read a single Task by id
  static Future<List<Map<String, dynamic>>> getTask(int id) async {
    final db = await SQLHelper.db();
    return db.query(tableName, where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an Task by id
  static Future<int> updateTask(
      {required int id,
      required String title,
      String? description,
      required String taskDate,
      required String taskStatus}) async {
    final db = await SQLHelper.db();

    final data = {
      'taskTitle': title,
      'taskDescription': description,
      'taskStatus': taskStatus,
      'taskDate': taskDate,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update(tableName, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a Task by id
  static Future<void> deleteTask(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
