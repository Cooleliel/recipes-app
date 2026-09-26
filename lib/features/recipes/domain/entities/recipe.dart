/// Recette (entité métier, Dart pur).
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.mealTypes,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final List<String> mealTypes;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
}