import '../core/utils/fake_delay.dart';
import '../models/food.dart';
import '../models/macros.dart';

/// Fake API for foods (in-memory mock data).
class MockFoodService {
  const MockFoodService();

  Future<List<Food>> fetchFoods() async {
    await fakeDelay();
    return _foods;
  }

  // Curated, gym-friendly list with macros per 100g.
  static const List<Food> _foods = [
    Food(
      id: 'chicken_breast',
      name: 'Pechuga de pollo',
      macrosPer100g: Macros(proteinG: 31, carbsG: 0, fatG: 3.6),
    ),
    Food(
      id: 'salmon',
      name: 'Salmón',
      macrosPer100g: Macros(proteinG: 20, carbsG: 0, fatG: 13),
    ),
    Food(
      id: 'eggs',
      name: 'Huevo',
      macrosPer100g: Macros(proteinG: 13, carbsG: 1.1, fatG: 11),
    ),
    Food(
      id: 'greek_yogurt',
      name: 'Yogur griego natural',
      macrosPer100g: Macros(proteinG: 10, carbsG: 3.6, fatG: 0.4),
    ),
    Food(
      id: 'oats',
      name: 'Avena',
      macrosPer100g: Macros(proteinG: 13.5, carbsG: 60, fatG: 7),
    ),
    Food(
      id: 'rice',
      name: 'Arroz cocido',
      macrosPer100g: Macros(proteinG: 2.7, carbsG: 28, fatG: 0.3),
    ),
    Food(
      id: 'potato',
      name: 'Patata cocida',
      macrosPer100g: Macros(proteinG: 2, carbsG: 17, fatG: 0.1),
    ),
    Food(
      id: 'banana',
      name: 'Plátano',
      macrosPer100g: Macros(proteinG: 1.1, carbsG: 23, fatG: 0.3),
    ),
    Food(
      id: 'olive_oil',
      name: 'Aceite de oliva',
      macrosPer100g: Macros(proteinG: 0, carbsG: 0, fatG: 100),
    ),
    Food(
      id: 'avocado',
      name: 'Aguacate',
      macrosPer100g: Macros(proteinG: 2, carbsG: 9, fatG: 15),
    ),
    Food(
      id: 'lentils',
      name: 'Lentejas cocidas',
      macrosPer100g: Macros(proteinG: 9, carbsG: 20, fatG: 0.4),
    ),
    Food(
      id: 'whey',
      name: 'Proteína whey (polvo)',
      macrosPer100g: Macros(proteinG: 80, carbsG: 8, fatG: 6),
    ),
    Food(
      id: 'almonds',
      name: 'Almendras',
      macrosPer100g: Macros(proteinG: 21, carbsG: 22, fatG: 50),
    ),
    Food(
      id: 'spinach',
      name: 'Espinacas',
      macrosPer100g: Macros(proteinG: 2.9, carbsG: 3.6, fatG: 0.4),
    ),
  ];
}

