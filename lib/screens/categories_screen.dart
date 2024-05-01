import 'package:flutter/material.dart';
import '../widgets/category_item.dart';
import '../data/database.dart'; // Adjust the path to match the location of database.dart
import '../Models/category.dart';
import 'category_meals_screen.dart'; // Import CategoryMealsScreen

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late List<Category> _categories = []; // Initialize _categories with an empty list

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    try {
      // Initialize database
      final dbHelper = DatabaseHelper();
      await dbHelper.initDatabase(); // Await database initialization
      print('Database initialized successfully.');

      // Preload initial data into _categories list
      _categories = [
        Category(
          id: 'c1',
          title: 'Italian',
          color: Colors.purple,
        ),
        Category(
          id: 'c2',
          title: 'Quick & Easy',
          color: Colors.red,
        ),Category(
          id: 'c3',
          title: 'Hamburgers',
          color: Colors.orange,
        ),
        Category(
          id: 'c4',
          title: 'German',
          color: Colors.amber,
        ),
        Category(
          id: 'c5',
          title: 'Light & Lovely',
          color: Colors.blue,
        ),
        Category(
          id: 'c6',
          title: 'Exotic',
          color: Colors.green,
        ),
        Category(
          id: 'c7',
          title: 'Breakfast',
          color: Colors.lightBlue,
        ),
        Category(
          id: 'c8',
          title: 'Asian',
          color: Colors.lightGreen,
        ),
        Category(
          id: 'c9',
          title: 'French',
          color: Colors.pink,
        ),
        Category(
          id: 'c10',
          title: 'Summer',
          color: Colors.teal,
        ),
      ];
      // Update state to trigger UI rebuild
      setState(() {});

      print('Categories preloaded successfully.');
    } catch (error) {
      print('Error initializing categories: $error');
      // Handle error if initialization fails
      setState(() {
        _categories = []; // Reset _categories to an empty list
      });
    }
  }

  void _selectCategory(BuildContext context, String categoryId) {
    Navigator.of(context).pushNamed(
      CategoryMealsScreen.routeName,
      arguments: {'id': categoryId}, // Pass category ID as route arguments
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _categories.isNotEmpty // Check if _categories is not empty before using it
          ? GridView(
        padding: const EdgeInsets.all(25),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: _categories.map((category) {
          return GestureDetector(
            onTap: () => _selectCategory(context, category.id), // Pass category ID when tapped
            child: CategoryItem(
              category.id,
              category.title,
              category.color,
            ),
          );
        }).toList(),
      )
          : Center(
        child:
        CircularProgressIndicator(), // Show loading indicator while categories are being fetched
      ),
    );
  }
}
