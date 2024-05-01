import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../Models/meal.dart';
import '../Models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'my_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create categories table
        await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          color TEXT NOT NULL
        )
      ''');

        // Create meals table
        await db.execute('''
        CREATE TABLE meals (
          id TEXT PRIMARY KEY,
          category_ids TEXT NOT NULL,
          title TEXT NOT NULL,
          image_url TEXT NOT NULL,
          ingredients TEXT NOT NULL,
          steps TEXT NOT NULL,
          duration INT NOT NULL,
          complexity TEXT NOT NULL,
          affordability TEXT NOT NULL,
          is_gluten_free INTEGER NOT NULL,
          is_vegan INTEGER NOT NULL,
          is_vegetarian INTEGER NOT NULL,
          is_lactose_free INTEGER NOT NULL
        )
      ''');

        // Create bookmarks table
        await db.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          meal_id TEXT NOT NULL,
          FOREIGN KEY (meal_id) REFERENCES meals (id)
        )
      ''');
      },
      // Set onUpgrade to handle database version upgrades
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Handle database migrations if needed
      },
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('categories');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        title: maps[i]['title'],
        color: Color(int.parse(maps[i]['color'])),
      );
    });
  }

  Future<List<Meal>> getMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('meals');
    return List.generate(maps.length, (i) {
      return Meal(
        id: maps[i]['id'],
        categories: maps[i]['category_ids'].split(','),
        title: maps[i]['title'],
        imageUrl: maps[i]['image_url'],
        ingredients: maps[i]['ingredients'].split(','),
        steps: maps[i]['steps'].split(','),
        duration: maps[i]['duration'],
        complexity: Complexity.values.firstWhere((e) => e.toString() == 'Complexity.' + maps[i]['complexity']),
        affordability: Affordability.values.firstWhere((e) => e.toString() == 'Affordability.' + maps[i]['affordability']),
        isGlutenFree: maps[i]['is_gluten_free'] == 1,
        isVegan: maps[i]['is_vegan'] == 1,
        isVegetarian: maps[i]['is_vegetarian'] == 1,
        isLactoseFree: maps[i]['is_lactose_free'] == 1,
      );
    });
  }

  Future<Meal> getMealById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Meal(
      id: maps[0]['id'],
      categories: maps[0]['category_ids'].split(','),
      title: maps[0]['title'],
      imageUrl: maps[0]['image_url'],
      ingredients: maps[0]['ingredients'].split(','),
      steps: maps[0]['steps'].split(','),
      duration: maps[0]['duration'],
      complexity: Complexity.values.firstWhere((e) => e.toString() == 'Complexity.' + maps[0]['complexity']),
      affordability: Affordability.values.firstWhere((e) => e.toString() == 'Affordability.' + maps[0]['affordability']),
      isGlutenFree: maps[0]['is_gluten_free'] == 1,
      isVegan: maps[0]['is_vegan'] == 1,
      isVegetarian: maps[0]['is_vegetarian'] == 1,
      isLactoseFree: maps[0]['is_lactose_free'] == 1,
    );
  }

  Future<void> insertOrUpdateMeal(Meal meal) async {
    final db = await database;
    await db!.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMeal(String mealId) async {
    final db = await database;
    await db!.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
  }

  Future<void> insertOrUpdateBookmark(String mealId) async {
    final db = await database;
    await db!.insert(
      'bookmarks',
      {'meal_id': mealId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String mealId) async {
    final db = await database;
    await db!.delete(
      'bookmarks',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );
  }

  Future<List<String>> getBookmarkedMealIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('bookmarks');
    return List.generate(maps.length, (i) {
      return maps[i]['meal_id'];
    });
  }

// Add other database operations here
}
