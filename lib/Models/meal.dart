enum Complexity { Simple, Challenging, Hard }

enum Affordability { Affordable, Pricey, Luxurious }

class Meal {
  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;

  const Meal({required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_ids': categories.join(','),
      'title': title,
      'affordability': affordability.toString().split('.')[1],
      'complexity': complexity.toString().split('.')[1],
      'image_url': imageUrl,
      'duration': duration,
      'ingredients': ingredients.join(','),
      'steps': steps.join(','),
      'is_gluten_free': isGlutenFree ? 1 : 0,
      'is_vegan': isVegan ? 1 : 0,
      'is_vegetarian': isVegetarian ? 1 : 0,
      'is_lactose_free': isLactoseFree ? 1 : 0,
    };
  }

  Meal copyWith({
    String? id,
    List<String>? categories,
    String? title,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? steps,
    int? duration,
    Complexity? complexity,
    Affordability? affordability,
    bool? isGlutenFree,
    bool? isLactoseFree,
    bool? isVegan,
    bool? isVegetarian,
  }) {
    return Meal(
      id: id ?? this.id,
      categories: categories ?? this.categories,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      duration: duration ?? this.duration,
      complexity: complexity ?? this.complexity,
      affordability: affordability ?? this.affordability,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isLactoseFree: isLactoseFree ?? this.isLactoseFree,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

}
