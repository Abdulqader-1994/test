import 'dart:math';

int getRandomColor() {
  List<int> colorValues = [
    4278190080, // Black
    4294967295, // White
    4294901760, // Red
    4278255360, // Green
    4278190335, // Blue
    4294967040, // Yellow
    4278255615, // Cyan
    4294902015, // Magenta
    4294944000, // Orange
    4294951115, // Pink
    4286578816, // Purple
    4289014310, // Brown
    4286611584, // Gray
    4278222976, // Teal
  ];

  int randomIndex = Random().nextInt(colorValues.length);
  return colorValues[randomIndex];
}
