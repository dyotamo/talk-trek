import 'dart:math' as math;

import 'package:flutter/material.dart';

const forbiddenNickname = 'eu';

const maxMessages = 50;

const colors = [
  Colors.amber,
  Colors.orange,
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.brown,
  Colors.tealAccent,
  Colors.purpleAccent,
  Colors.deepOrange,
  Colors.indigoAccent,
];

final userColors = <String, Color>{};

Color getColor(String username) {
  var color = userColors[username];
  if (color == null) {
    final rnd = math.Random();
    return userColors[username] = colors[rnd.nextInt(colors.length)];
  }

  return color;
}
