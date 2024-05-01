import 'package:flutter/material.dart';
import '../widgets/meal_item.dart';
import '../Models/meal.dart';
import '../data/database.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Meal> _favoriteMeals = [];

  @override
  void initState() {
    _loadFavoriteMealsFromDatabase();
    super.initState();
  }

  Future<void> _loadFavoriteMealsFromDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      final bookmarkedMealIds = await dbHelper.getBookmarkedMealIds();
      final List<Meal> favoriteMeals = [];
      for (var mealId in bookmarkedMealIds) {
        final meal = await dbHelper.getMealById(mealId);
        favoriteMeals.add(meal);
      }
      setState(() {
        _favoriteMeals = favoriteMeals;
      });
    } catch (error) {
      print('Error loading favorite meals: $error');
    }
  }

  Future<void> _toggleFavorite(String mealId) async {
    final dbHelper = DatabaseHelper();
    final isFavorite = _favoriteMeals.any((meal) => meal.id == mealId);
    if (isFavorite) {
      await dbHelper.deleteBookmark(mealId);
    } else {
      await dbHelper.insertOrUpdateBookmark(mealId);
    }
    _loadFavoriteMealsFromDatabase();
  }

  bool isMealFavorite(String mealId) {
    return _favoriteMeals.any((meal) => meal.id == mealId);
  }

  @override
  Widget build(BuildContext context) {
    if (_favoriteMeals.isEmpty) {
      return Center(
        child: Text(
          'You have no Favorites--Start Adding Some',
          style: TextStyle(color: Colors.grey[900], fontSize: 19),
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (ctx, index) {
          return MealItem(
            id: _favoriteMeals[index].id,
            title: _favoriteMeals[index].title,
            imageUrl: _favoriteMeals[index].imageUrl,
            duration: _favoriteMeals[index].duration,
            complexity: _favoriteMeals[index].complexity,
            affordability: _favoriteMeals[index].affordability,
          );
          // return Text(favoriteMeals[index].title);
        },
        itemCount: _favoriteMeals.length,
      );
    }
  }
}

