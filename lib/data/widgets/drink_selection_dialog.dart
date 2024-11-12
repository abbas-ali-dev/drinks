import 'package:drinks/models/drink_model.dart'; // Import your Drink model
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DrinkSelectionDialog extends StatefulWidget {
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
  State<DrinkSelectionDialog> createState() => _DrinkSelectionDialogState();
}

class _DrinkSelectionDialogState extends State<DrinkSelectionDialog> {
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the current drink's note
    _noteController.text = widget.currentDrink.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
                      dateTime: widget.currentDrink.dateTime,
                      drinkType: drink["name"],
                      note: _noteController.text, // Add the note here
                    );
                    widget.onDrinkSelected(newDrink);
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
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                keyboardType: TextInputType.text,
                maxLines: 1,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Note about drink',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 6.h,
              width: 60.w,
              child: ElevatedButton(
                onPressed: widget.onDeleteDrink,
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
