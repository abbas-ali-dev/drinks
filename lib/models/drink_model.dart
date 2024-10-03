import 'package:hive/hive.dart';

// part 'drink_model.g.dart'; // Important for Hive code generation

@HiveType(typeId: 0) // Assign a unique type ID to your model
class Drink {
  @HiveField(0)
  final DateTime dateTime;

  @HiveField(1)
  final String drinkType;

  Drink({required this.dateTime, required this.drinkType});
}
