// drink_model.dart
import 'package:hive/hive.dart';

part 'drink_model.g.dart';

@HiveType(typeId: 0)
class Drink {
  @HiveField(0)
  late DateTime dateTime;

  @HiveField(1)
  final String drinkType;

  @HiveField(2)
  final String? note;

  Drink({required this.dateTime, required this.drinkType, this.note});
}
