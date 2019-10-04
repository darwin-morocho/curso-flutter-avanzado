import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class Responsive {
  double width, height, inch;

  Responsive(BuildContext context) {
    final size = MediaQuery.of(context).size;

    width = size.width;
    height = size.height;

    // c2=a2+b2 => c = sqrt(a2+b2)

    inch = math.sqrt(math.pow(width, 2) + math.pow(height, 2));
  }

  double wp(double percent) {
    return width * percent / 100;
  }


  double hp(double percent) {
    return height * percent / 100;
  }


  double ip(double percent) {
    return inch * percent / 100;
  }
}
