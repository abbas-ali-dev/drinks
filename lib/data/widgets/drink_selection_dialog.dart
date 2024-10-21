import 'package:drinks/models/drink_model.dart'; // Import your Drink model
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DrinkSelectionDialog extends StatelessWidget {
  final Drink currentDrink; // The drink to potentially modify
  final Function(Drink) onDrinkSelected; // Callback to update the drink
  final Function() onDeleteDrink; // Callback to delete the drink

  const DrinkSelectionDialog({
    Key? key,
    required this.currentDrink,
    required this.onDrinkSelected,
    required this.onDeleteDrink, // Add the delete callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List totalDrinks = [
      {"name": "drink", "image": Image.asset("assets/png/drink.png")},
      {"name": "wine", "image": Image.asset("assets/png/wine.png")},
      {"name": "beer", "image": Image.asset("assets/png/beer.png")},
    ];

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      content: SizedBox(
        width: 60.w,
        height: 30.h, // Increased height for text field and button
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: totalDrinks.map((drink) {
                return GestureDetector(
                  onTap: () {
                    final newDrink = Drink(
                      dateTime: currentDrink.dateTime,
                      drinkType: drink["name"],
                    );
                    onDrinkSelected(newDrink);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 15.w,
                        child: drink["image"],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(color: Colors.grey, thickness: 2),
            const Padding(
              padding: EdgeInsets.only(left: 40, top: 10, bottom: 10),
              child: TextField(
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Note about drink',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none, // Remove the underline
                ),
              ),
            ),
            SizedBox(
              height: 6.h,
              width: 60.w,
              child: ElevatedButton(
                onPressed: onDeleteDrink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('DELETE',
                    style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
