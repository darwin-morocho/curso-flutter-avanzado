import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class Responsive {
  double inch;

  Responsive(BuildContext context) {
    final size = MediaQuery.of(context).size;
    inch = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));
  }

  double ip(double percent) {
    return inch * percent / 100;
  }
}
