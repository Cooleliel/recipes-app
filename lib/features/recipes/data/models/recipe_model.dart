import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';

/// Modèle de la couche Data : l'entité [Recipe] + la conversion JSON.
///
/// Les clés sont celles de la table Postgres `recipes` (snake_case).
/// Le même format sert pour l'API et pour le cache Hive.
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.ingredients,
    required super.instructions,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.servings,
    required super.difficulty,
    required super.cuisine,
    required super.caloriesPerServing,
    required super.tags,
    required super.mealTypes,
    required super.imageUrl,
    required super.rating,
    required super.reviewCount,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      ingredients: _stringList(json['ingredients']),
      instructions: _stringList(json['instructions']),
      prepTimeMinutes: _int(json['prep_time_minutes']),
      cookTimeMinutes: _int(json['cook_time_minutes']),
      servings: _int(json['servings']),
      difficulty: (json['difficulty'] as String?) ?? '',
      cuisine: (json['cuisine'] as String?) ?? '',
      caloriesPerServing: _int(json['calories_per_serving']),
      tags: _stringList(json['tags']),
      mealTypes: _stringList(json['meal_type']),
      imageUrl: (json['image'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: _int(json['review_count']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'ingredients': ingredients,
        'instructions': instructions,
        'prep_time_minutes': prepTimeMinutes,
        'cook_time_minutes': cookTimeMinutes,
        'servings': servings,
        'difficulty': difficulty,
        'cuisine': cuisine,
        'calories_per_serving': caloriesPerServing,
        'tags': tags,
        'meal_type': mealTypes,
        'image': imageUrl,
        'rating': rating,
        'review_count': reviewCount,
      };

  /// La couche Data renvoie toujours une entité, jamais un modèle.
  Recipe toEntity() => Recipe(
        id: id,
        name: name,
        ingredients: ingredients,
        instructions: instructions,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        servings: servings,
        difficulty: difficulty,
        cuisine: cuisine,
        caloriesPerServing: caloriesPerServing,
        tags: tags,
        mealTypes: mealTypes,
        imageUrl: imageUrl,
        rating: rating,
        reviewCount: reviewCount,
      );

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  static List<String> _stringList(Object? value) => value is List<dynamic>
      ? value.map((dynamic item) => item.toString()).toList()
      : <String>[];
}