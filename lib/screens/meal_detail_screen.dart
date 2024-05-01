import 'package:flutter/material.dart';
import '../data/database.dart'; // Adjust this path as needed
import '../Models/meal.dart';

class MealDetailScreen extends StatefulWidget {
  static const routeName = '/meal-detail';
  final Function _toggleFavorite;
  final Function isMealFavorite;

  MealDetailScreen(this._toggleFavorite, this.isMealFavorite);

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Meal _selectedMeal;

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amberAccent,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 150,
      width: 300,
      child: child,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mealId = ModalRoute
        .of(context)!
        .settings
        .arguments as String;
    _fetchMeal(mealId);
  }

  Future<void> _fetchMeal(String mealId) async {
    final meal = await DatabaseHelper().getMealById(
        mealId); // Corrected method name
    setState(() {
      _selectedMeal = meal;
    });
  }

  Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme
            .of(context)
            .textTheme
            .headline6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMeal == null) {
      // Show loading indicator if _selectedMeal is null
      return Scaffold(
        appBar: AppBar(title: Text('Loading')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      // Build UI with _selectedMeal data
      return Scaffold(
        appBar: AppBar(title: Text(_selectedMeal.title ?? 'Meal Detail')),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  _selectedMeal.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              buildSectionTitle(context, 'Ingredients'),
              buildContainer(
                ListView.builder(
                  itemBuilder: (context, index) =>
                      Card(
                        color: Colors.amberAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Text(
                            _selectedMeal.ingredients.length > index
                                ? _selectedMeal.ingredients[index]
                                : '', // Check if index is valid
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText2,
                          ),
                        ),
                      ),
                  itemCount: _selectedMeal.ingredients.length,
                  shrinkWrap: true,
                ),
              ),
              buildSectionTitle(context, 'Steps'),
              buildContainer(
                ListView.builder(
                  itemBuilder: (context, index) =>
                      Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Text('# ${index + 1}'),
                            ),
                            title: Text(
                              _selectedMeal.steps.length > index
                                  ? _selectedMeal.steps[index]
                                  : '', // Check if index is valid
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                  itemCount: _selectedMeal.steps.length,
                  shrinkWrap: true,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final dbHelper = DatabaseHelper();
            final isFavorite = widget.isMealFavorite(_selectedMeal.id);
            try {
              if (isFavorite) {
                // If the meal is already bookmarked, delete the bookmark
                await dbHelper.deleteBookmark(_selectedMeal.id);
              } else {
                // If the meal is not bookmarked, insert a bookmark
                await dbHelper.insertOrUpdateBookmark(_selectedMeal.id);
              }
              // Update the UI to reflect the change in bookmark status
              widget._toggleFavorite(_selectedMeal.id);
            } catch (error) {
              print('Error toggling bookmark: $error');
            }
          },
          child: Icon(
            widget.isMealFavorite(_selectedMeal.id) ? Icons.star : Icons.star_border,
          ),
        ),
      );
    }
  }
}
