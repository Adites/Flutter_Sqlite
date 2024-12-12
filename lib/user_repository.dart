import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';

class UserRepository {
  late Database _database;

  Future<void> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        );
      },
    );
  }

  Future<List<User>> fetchUsersFromApi() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> saveUsersToDatabase(List<User> users) async {
    final batch = _database.batch();
    for (var user in users) {
      batch.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<User>> getUsersFromDatabase({String? searchQuery}) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'users',
      where: searchQuery != null ? 'name LIKE ?' : null,
      whereArgs: searchQuery != null ? ['%$searchQuery%'] : null,
      orderBy: 'name ASC',
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }
}
