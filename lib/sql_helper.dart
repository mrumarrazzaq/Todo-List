import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

const String tableName = 'TODO';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        taskTitle TEXT,
        taskDescription TEXT,
        taskStatus STRING,
        taskDate STRING,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
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

  // Create new item (journal)
  static Future<int> createItem(
      {required String taskTitle,
      String? taskDescription,
      required String taskDate,
      required String taskStatus}) async {
    final db = await SQLHelper.db();

    final data = {
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'taskStatus': taskStatus,
      'taskDate': taskStatus,
    };
    final id = await db.insert(tableName, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query(tableName, orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query(tableName, where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      {required int id,
      required String taskTitle,
      String? taskDescription,
      required String taskDate,
      required String taskStatus}) async {
    final db = await SQLHelper.db();

    final data = {
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'taskStatus': taskStatus,
      'taskDate': taskDate,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update(tableName, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
