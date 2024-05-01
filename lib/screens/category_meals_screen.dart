import 'package:flutter/material.dart';
import '../widgets/meal_item.dart';
import '../Models/meal.dart';
import '../Models/category.dart';
import '../data/database.dart';

class CategoryMealsScreen extends StatefulWidget {
  static const routeName = '/category-meals';

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  String? categoryTitle;
  List<Meal>? displayedMeals;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final routeArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final categoryId = routeArgs['id'];

    try {
      final dbHelper = DatabaseHelper();
      final categories = await dbHelper.getCategories();
      final selectedCategory = categories.firstWhere(
              (category) => category.id == categoryId,
          orElse: () => Category(id: '', title: ''));
      setState(() {
        categoryTitle = selectedCategory.title;
      });

      final meals = await dbHelper.getMeals();
      setState(() {
        displayedMeals = meals
            .where((meal) => meal.categories.contains(categoryId))
            .toList();
      });
    } catch (error) {
      print('Error fetching category meals: $error');
      setState(() {
        categoryTitle = 'Error';
        displayedMeals = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryTitle ?? '')),
      body: displayedMeals != null && displayedMeals!.isNotEmpty
          ? ListView.builder(
        itemBuilder: (ctx, index) {
          return MealItem(
            id: displayedMeals![index].id,
            title: displayedMeals![index].title,
            imageUrl: displayedMeals![index].imageUrl,
            duration: displayedMeals![index].duration,
            complexity: displayedMeals![index].complexity,
            affordability: displayedMeals![index].affordability,
          );
        },
        itemCount: displayedMeals!.length,
      )
          : Center(
        child: Text('No meals found for this category!'),
      ),
    );
  }
}
