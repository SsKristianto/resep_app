import 'package:flutter/material.dart';
import '../Models/meal.dart';
import '../data/database.dart'; // Import the database helper class

class RecipeScreen extends StatefulWidget {
  static const routeName = '/recipe';

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late List<Meal> _meals = [];
  Complexity enteredComplexity = Complexity.Simple;
  Affordability enteredAffordability = Affordability.Affordable;

  @override
  void initState() {
    _loadMealsFromDatabase();
    super.initState();
  }

  Future<void> _loadMealsFromDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      final meals = await dbHelper.getMeals();
      setState(() {
        _meals = meals;
      });
    } catch (error) {
      print('Error loading meals: $error');
    }
  }

  Future<void> _removeMeal(String mealId) async {
    try {
      final dbHelper = DatabaseHelper();

      // Hapus semua bookmark yang terkait
      await dbHelper.deleteBookmark(mealId);

      // Hapus meal dari meals
      await dbHelper.deleteMeal(mealId);

      setState(() {
        _meals.removeWhere((meal) => meal.id == mealId);
      });
    } catch (error) {
      print('Error removing meal: $error');
    }
  }



  Future<void> _showAddEditMealDialog({Meal? meal}) async {
    TextEditingController titleController =
    TextEditingController(text: meal?.title ?? '');
    TextEditingController imageUrlController =
    TextEditingController(text: meal?.imageUrl ?? '');
    TextEditingController categoriesController = TextEditingController(
        text: meal?.categories.join(', ') ?? '');
    TextEditingController ingredientsController = TextEditingController(
        text: meal?.ingredients.join('\n') ?? '');
    TextEditingController stepsController =
    TextEditingController(text: meal?.steps.join('\n') ?? '');
    TextEditingController durationController = TextEditingController(
        text: meal?.duration.toString() ?? '');
    bool isGlutenFree = meal?.isGlutenFree ?? false;
    bool isVegan = meal?.isVegan ?? false;
    bool isVegetarian = meal?.isVegetarian ?? false;
    bool isLactoseFree = meal?.isLactoseFree ?? false;
    bool isEditing = meal != null;

    String? mealId = meal?.id;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Meal' : 'Add Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: titleController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Image URL'),
                controller: imageUrlController,
              ),
              TextField(
                decoration:
                InputDecoration(labelText: 'Categories (EX : c1,c2,..,c10)'),
                controller: categoriesController,
              ),
              TextField(
                decoration:
                InputDecoration(labelText: 'Ingredients (one per line)'),
                controller: ingredientsController,
                maxLines: null,
              ),
              TextField(
                decoration:
                InputDecoration(labelText: 'Steps (one per line)'),
                controller: stepsController,
                maxLines: null,
              ),
              DropdownButtonFormField<Complexity>(
                value: enteredComplexity,
                onChanged: (newValue) {
                  setState(() {
                    enteredComplexity = newValue ?? Complexity.Simple;
                  });
                },
                items: Complexity.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString().split('.')[1]),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Complexity'),
              ),
              DropdownButtonFormField<Affordability>(
                value: enteredAffordability,
                onChanged: (newValue) {
                  setState(() {
                    enteredAffordability = newValue ?? Affordability.Affordable;
                  });
                },
                items: Affordability.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString().split('.')[1]),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Affordability'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                controller: durationController,
              ),
              Row(
                children: [
                  Text('Gluten Free: '),
                  Checkbox(
                    value: isGlutenFree,
                    onChanged: (newValue) {
                      setState(() {
                        isGlutenFree = newValue ?? false;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Vegan: '),
                  Checkbox(
                    value: isVegan,
                    onChanged: (newValue) {
                      setState(() {
                        isVegan = newValue ?? false;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Vegetarian: '),
                  Checkbox(
                    value: isVegetarian,
                    onChanged: (newValue) {
                      setState(() {
                        isVegetarian = newValue ?? false;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Lactose Free: '),
                  Checkbox(
                    value: isLactoseFree,
                    onChanged: (newValue) {
                      setState(() {
                        isLactoseFree = newValue ?? false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final enteredTitle = titleController.text;
              final enteredImageUrl = imageUrlController.text;
              final enteredCategories = categoriesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList();
              final enteredIngredients = ingredientsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .toList();
              final enteredSteps = stepsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .toList();
              final enteredDuration =
                  int.tryParse(durationController.text) ?? 0;

              if (enteredTitle.isEmpty ||
                  enteredImageUrl.isEmpty ||
                  enteredCategories.isEmpty ||
                  enteredIngredients.isEmpty ||
                  enteredSteps.isEmpty) {
                return;
              }

              final newMeal = Meal(
                id: isEditing ? mealId! : DateTime.now().toString(),
                title: enteredTitle,
                imageUrl: enteredImageUrl,
                categories: enteredCategories,
                ingredients: enteredIngredients,
                steps: enteredSteps,
                duration: enteredDuration,
                complexity: enteredComplexity,
                affordability: enteredAffordability,
                isGlutenFree: isGlutenFree,
                isLactoseFree: isLactoseFree,
                isVegan: isVegan,
                isVegetarian: isVegetarian,
              );

              final dbHelper = DatabaseHelper();
              if (isEditing) {
                try {
                  await dbHelper.insertOrUpdateMeal(newMeal);
                  final index = _meals.indexWhere((element) => element.id == mealId);
                  if (index != -1) {
                    setState(() {
                      _meals[index] = newMeal;
                    });
                  }
                } catch (error) {
                  print('Error inserting/updating meal: $error');
                }
              } else {
                try {
                  await dbHelper.insertOrUpdateMeal(newMeal);
                  setState(() {
                    _meals.add(newMeal);
                  });
                } catch (error) {
                  print('Error inserting/updating meal: $error');
                }
              }

              setState(() {});
              Navigator.of(ctx).pop();
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Meal'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add, Edit and Delete'),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          return ListTile(
            title: Text(_meals[index].title),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeMeal(_meals[index].id),
            ),
            onTap: () => _showAddEditMealDialog(meal: _meals[index]),
          );
        },
        itemCount: _meals.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditMealDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
